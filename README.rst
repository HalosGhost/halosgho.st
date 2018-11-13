hgweb
=====

This is my homepage, rewritten from the ground up in lwan so it is entirely in C.
Right now, it is nothing flashy (very similar to the Haskell version); project pages (and perhaps a few other treats) are planned for the near future.

The Stack
---------

* `lwan <https://lwan.ws/>`_ - used as a library to build the webserver and page logic
* `hitch <https://hitch-tls.org/>`_ - TLS-terminating proxy server
* `acme-client (portable) <https://kristaps.bsd.lv/acme-client/>`_ - an ACME-protocol client for TLS Cert renewal

All running on Arch Linux using `nftables <https://netfilter.org/projects/nftables/>`_ for traffic redirection and forwarding

Design Characteristics
----------------------

* `Secure Header Configuration <https://securityheaders.com/?q=halosgho.st&followRedirects=on>`_
* `Secure TLS Configuration <https://www.ssllabs.com/ssltest/analyze.html?d=halosgho.st>`_
* `Good Accessibility <http://wave.webaim.org/report#/http://halosgho.st>`_
* `High Performance <https://gtmetrix.com/reports/halosgho.st/pXtTFfZV/latest>`_
* `Valid, Modern, Semantic Markup <https://validator.nu/?doc=https%3A%2F%2Fhalosgho.st>`_
* `Valid Styles <https://jigsaw.w3.org/css-validator/validator?uri=halosgho.st>`_

