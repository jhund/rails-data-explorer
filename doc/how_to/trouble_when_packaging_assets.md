Trouble when packaging assets
=============================

I had syntax and dot errors when packaging the JS assets. Turns out that the
JS libraries used reserved words as method accessors. Here is an example how I
fixed it (`in`) is the reserved word:

`c.in` => `c["in"]`
