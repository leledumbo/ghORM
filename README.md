<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=7WRXRMDSM72W8&lc=ID&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted">
  <img src="https://www.paypalobjects.com/en_US/GB/i/btn/btn_donateCC_LG.gif" />
</a>

# ghORM

## !! IMPORTANT INFORMATION !!
ghORM has been branched to ghORM-OG and ghORM-NG.

OG (Old Generation) consists of earlier implementation which is stuck at relationship feature that I'm not capable enough to implement. I left it at the latest state I can do in case someday someone is willing to revive it when one found a way to implement the missing relationship features.

NG (New Generation) is my new attempt that has successfully implement the relationship features, both 1-N and M-N using a different approach from OG branch. The NG implementation does not use RTTI and instead let the user override certain methods and do the mapping manually. This also increase flexibility in the naming. One doesn't need to have matching class <-> table name and property <-> column name. The current implementation is rather complex to use and has traps to watch out, but works. At user (of the resulting model) level, the POV stays the same: No SQL or Greyhound stuffs exposed.

## README

Object Relational Mapping unit built on top of Greyhound Project - https://github.com/mdbs99/Greyhound

Greyhound project is a great ORM-ish (thus, **not** true ORM) project to ease database access from Free Pascal, by abstracting the backend and simple data retrieval (with filtering), insertion and update. However, by design Greyhound has the following features:

* It use SQL as query language and does not try to create a complex **abstraction between objects and tables**
* It allows developers to have **greater control of SQL rather than relying on the framework to generate it automatically**

Those **bold** parts are what ghORM fills. Using ghORM, data can be inserted, retrieved and updated in a more abstract manner so the user doesn't need to touch SQL as far as possible. But the unit doesn't try to hide SQL from user. If necessary, an access to Greyhound table instance is provided.

Take a look at the unit tests on how to use the unit.
