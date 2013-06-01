#WebGL Brasil

Seleção do melhor conteúdo de WebGL, traduzidos em português.

## Getting Started

1. [Install DocPad](https://github.com/bevry/docpad)

1. Clone the project and run the server

	``` bash
	git clone git://github.com/webglbrasil.git
	npm install
	docpad run
	```

1. [Open http://localhost:9778/](http://localhost:9778/)

1. Start modifying the `src` directory


## Structure

This project uses [DocPad](https://github.com/bevry/docpad), a static generator in NodeJS, and here's the basic structure:

<pre>
.
|-- out/
|-- src/
|   |-- documents
|   |-- files
|   |-- layouts
|   |-- partials
|   |-- posts
|   |-- translate
`-- package.json
`-- docpad.coffee
`-- grunt.js
`-- grunt-config.json
</pre>

#### out/

This is where the generated files are stored, once DocPad has been run. However, this directory is unnecessary for versioning, so it is ignored (.gitignore).

*This topic is based on [Browser Diet README file](http://github.com/zenorocha/browser-diet/blob/master/README.md)

## Team

### Creator

[![Vagner Santana](http://gravatar.com/avatar/d050e3a593aa5c49738028ade14606ed?s=70)](http://vagnersantana.com) |
--- | --- | --- | --- | --- | --- | ---
[Vagner Santana](http://vagnersantana.com)<br>[@vagnervjs](http://twitter.com/vagnervjs)|


## License

- Code is under MIT license
- Content is under Creative Commons BY-SA 3.0