<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=7WRXRMDSM72W8&lc=ID&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted">
  <img src="https://www.paypalobjects.com/en_US/GB/i/btn/btn_donateCC_LG.gif" />
</a>

ghORM
=====

Object Relational Mapping unit built on top of Greyhound Project - https://github.com/mdbs99/Greyhound

Greyhound project is a great ORM-ish (thus, **not** true ORM) project to ease database access from Free Pascal, by abstracting the backend and simple data retrieval (with filtering), insertion and update. However, by design Greyhound has the following features:

* It use SQL as query language and does not try to create a complex **abstraction between objects and tables**
* It allows developers to have **greater control of SQL rather than relying on the framework to generate it automatically**

Those **bold** parts are what ghORM fills. Using ghORM, data can be inserted, retrieved and updated in a more abstract manner so the user doesn't need to touch SQL as far as possible. But the unit doesn't try to hide SQL from user. If necessary, an access to Greyhound table instance is provided.

Take a look at the unit tests on how to use the unit.
