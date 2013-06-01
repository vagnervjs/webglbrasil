pathUtil = require('path')
slug = require('slug')
moment = require('moment')
juice = require('juice')
fs = require('fs')

docpadConfig = {

	collections:
		# todos posts
		posts: (database) ->
			@getCollection("html").createChildCollection()
				.setFilter('posts', (model) ->
					relativePath = pathUtil.dirname(model.attributes.fullPath).substr((__dirname+'/src/').length)
					return relativePath.indexOf('posts/') == 0
				)
				.setComparator({date: -1})
				.live()

		# # artigos == posts sem eventos
		# artigos: (database) ->
		# 	# posts de eventos
		# 	@getCollection("posts").createChildCollection()
		# 		.setFilter('eventos', (model) ->
		# 			relativePath = pathUtil.dirname(model.attributes.fullPath).substr((__dirname+'/src/').length)
		# 			return relativePath != 'posts/eventos'
		# 		)
		# 		.live()

	# =================================
	# Template Data
	# These are variables that will be accessible via our templates
	# To access one of these within our templates, refer to the FAQ: https://github.com/bevry/docpad/wiki/FAQ

	templateData:
		site:
			url: "http://webglbrasil.com"
			title: "WebGL Brasil"
			description: """
				Aprenda WebGL, em português!
				"""
			keywords: """
				webgl, brasil, webglbrasil, html5, front-ent, 3d, canvas
				"""
			author:
				name: 'Vagner Santana'
			production_url: 'http://webglbrasil.com'
		
		# -----------------------------
		# Helper Functions
		
		getLayoutName: (post) ->
			post.layout.replace(/\..*/, '')

		slug: (text) ->
			slug(text)

		raw: (content_fn) ->
			content_fn().toString()

		dateAsText: (date, prefix) ->
			# se for mais de 75 dias, mostra data; senão mostra x dias atrás
			# if (new Date().getTime() - date.getTime() > 75 * 24 * 60 * 60 * 1000)
				(if prefix? then prefix else '') + moment(date).lang('pt').format('DD MMM YYYY')
			# else
			#	moment(date).lang('pt').fromNow()

		encodedAbsoluteURI: (post) ->
			encodeURIComponent(@absoluteURI(post))

		absoluteURI: (post) ->
			relativePath = pathUtil.dirname(post.fullPath).substr((__dirname+'/src/').length)

			if post.url == '/' # home
				@site.production_url
			else if relativePath.indexOf('files') == 0 # html estatico, nao post
				@site.production_url + post.fullPath.replace(/.+src\/files/, '')
			else if @getLayoutName(post) == 'redirect' # post externo
				post.originalURI
			else # post ou pagina normal
				@site.production_url + post.url + '/'

		encodedTitle: (post) ->
			encodeURIComponent(post.title)

		code: (lang, code) ->
			code = code()
			lines = code.split /\r?\n/

			code = ''
			spaces = undefined
			for line, i in lines
				# skip first and last line if empty
				if (i == 0 or i == lines.length - 1) and (line.match(/^\s*$/))
					continue

				# get first line space
				if not spaces
					spaces = /^\s*/.exec(line)[0]

				# get this line without initial spaces
				code += line.replace(new RegExp('^' + spaces), '') + '\n'

			"""<pre><code class="lang-#{lang}">#{code}</code></pre>"""

		prepareFeed: (html) ->
			# TODO reescrever base dos href e src pra absoluto??
			css = fs.readFileSync('src/documents/style/base/feed.css', 'UTF-8')
			result = juice.inlineContent(html, css)
			result.replace /figcaption/g, 'em'

		# Others
		getPreparedTitle: ->
			# if we have a document title, then we should use that and suffix the site's title onto it
			if @document.title
				"#{@document.title} | #{@site.title}"
			# if our document does not have it's own title, then we should just use the site's title
			else
				@site.title

		# Get the prepared site/document description
		getPreparedDescription: ->
			# if we have a document description, then we should use that, otherwise use the site's description
			@document.description or @site.description

		# Get the prepared site/document keywords
		getPreparedKeywords: ->
			# Merge the document keywords with the site keywords
			@site.keywords.concat(@document.keywords or []).join(', ')

		getGruntedStyles: ->
			_ = require 'underscore'
			styles = []
			gruntConfig = require('./grunt-config.json')
			_.each gruntConfig, (value, key) ->
				styles = styles.concat _.flatten _.pluck value, 'dest'
			styles = _.filter styles, (value) ->
				return value.indexOf('.min.css') > -1
			_.map styles, (value) ->
				return value.replace 'out', ''

		getGruntedScripts: ->
			_ = require 'underscore'
			scripts = []
			gruntConfig = require('./grunt-config.json')
			_.each gruntConfig, (value, key) ->
				scripts = scripts.concat _.flatten _.pluck value, 'dest'
			scripts = _.filter scripts, (value) ->
				return value.indexOf('.min.js') > -1
			_.map scripts, (value) ->
				return value.replace 'out', ''


	# =================================
	# DocPad Events

	# Here we can define handlers for events that DocPad fires
	# You can find a full listing of events on the DocPad Wiki
	events:

		# Server Extend
		# Used to add our own custom routes to the server before the docpad routes are added
		serverExtend: (opts) ->
			# Extract the server from the options
			{server} = opts
			docpad = @docpad

			# As we are now running in an event,
			# ensure we are using the latest copy of the docpad configuraiton
			# and fetch our urls from it
			latestConfig = docpad.getConfig()
			oldUrls = latestConfig.templateData.site.oldUrls or []
			newUrl = latestConfig.templateData.site.url

			# Redirect any requests accessing one of our sites oldUrls to the new site url
			server.use (req,res,next) ->
				if req.headers.host in oldUrls
					res.redirect(newUrl+req.url, 301)
				else
					next()

		# Write After
		# Used to minify our assets with grunt
		writeAfter: (opts,next) ->
			# Prepare
			docpad = @docpad
			rootPath = docpad.config.rootPath
			balUtil = require 'bal-util'
			_ = require 'underscore'

			# Make sure to register a grunt `default` task
			command = ["#{rootPath}/node_modules/.bin/grunt", 'default']
			
			# Execute
			balUtil.spawn command, {cwd:rootPath,output:true}, ->
				src = []
				gruntConfig = require './grunt-config.json'
				_.each gruntConfig, (value, key) ->
					src = src.concat _.flatten _.pluck value, 'src'
				_.each src, (value) ->
					balUtil.spawn ['rm', value], {cwd:rootPath, output:false}, ->
				balUtil.spawn ['find', '.', '-type', 'd', '-empty', '-exec', 'rmdir', '{}', '\;'], {cwd:rootPath+'/out', output:false}, ->
				next()

			# Chain
			@

	plugins:
		highlightjs:
			aliases:
				stylus: 'css'
				less: 'css'
				text: 'ini'

	documentsPaths: [
		'documents',
		'posts/2013'
	]

}

# Export the DocPad Configuration
module.exports = docpadConfig