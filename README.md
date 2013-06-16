ghORM
=====

Object Relational Mapping unit built on top of Greyhound Project - https://github.com/mdbs99/Greyhound

Greyhound project is a great ORM-ish (thus, **not** true ORM) project to ease database access from Free Pascal, by abstracting the backend and simple data retrieval (with filtering), insertion and update. However, by design Greyhound has the following features:

* It use SQL as query language and does not try to create a complex **abstraction between objects and tables**
* It allows developers to have **greater control of SQL rather than relying on the framework to generate it automatically**

Those **bold** parts are what ghORM fills. Using ghORM, data can be inserted, retrieved and updated in a more abstract manner so the user doesn't need to touch SQL as far as possible. But the unit doesn't try to hide SQL from user. If necessary, an access to Greyhound table instance is provided.

Take a look at the unit tests on how to use the unit.

<form action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_top">
<input type="hidden" name="cmd" value="_s-xclick">
<input type="hidden" name="encrypted" value="-----BEGIN PKCS7-----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-----END PKCS7-----
">
<input type="image" src="https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!">
<img alt="" border="0" src="https://www.paypalobjects.com/en_US/i/scr/pixel.gif" width="1" height="1">
</form>
