# Predict
This is a web application meant to show case a data vizualization library which you will find under the app/canvas directory.
The library has not yet been extracted from this example web app.

As seen below, it renders and animates data in a scatter chart, plotted by time vs. percentage accuracy.

![alt tag](http://gyazo.com/a167066d3f2418a75980b7bfff050135.gif)

The library structures views using the hierarchy Widget > Layer > Group > Shape.  A widget is essentially a container in which to render Layers, and each Layer has a dedicated <cavnas> node and tweening engine.  This makes it so parts of the screen can animate without having to redraw all other shapes (e.g. new data coming in will not animate the percentage axis, but will animate the existing/new/old date points).

## Getting started
* Install (if you don't have them):
    * [Node.js](http://nodejs.org): `brew install node` on OS X
    * [Brunch](http://brunch.io): `npm install -g brunch`
    * [Bower](http://bower.io): `npm install -g bower`
    * Brunch plugins and Bower dependencies: `npm install & bower install`.
* Run:
    * `brunch watch --server` — watches the project with continuous rebuild. This will also launch HTTP server with [pushState](https://developer.mozilla.org/en-US/docs/Web/Guide/API/DOM/Manipulating_the_browser_history).
    * `brunch build --production` — builds minified project for production
* Learn:
    * `public/` dir is fully auto-generated and served by HTTP server.  Write your code in `app/` dir.
    * Place static files you want to be copied from `app/assets/` to `public/`.
    * [Brunch site](http://brunch.io), [Chaplin site](http://chaplinjs.org)
