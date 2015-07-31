Q = require 'q'
ldapjs = require 'ldapjs'
ldapjsCrowd = require 'ldapjs-crowd'
fs = require 'fs'

configFile = process.argv[2]
configJson = fs.readFileSync configFile
config = JSON.parse configJson

SSL_END_CERTIFICATE = '-----END CERTIFICATE-----\n'
SSL_END_CERTIFICATE_LENGTH = SSL_END_CERTIFICATE.length

opts = require('https').globalAgent.options
if config.ssl.certificateBundle
  opts.ca = opts.ca || []
  certs = fs.readFileSync config.ssl.certificateBundle
  while certs.length
    end = certs.indexOf SSL_END_CERTIFICATE
    offset = end + SSL_END_CERTIFICATE_LENGTH
    opts.ca.push certs.substring 0, offset
    certs = certs.substring offset
if config.crowd.sslRootCertificate
  opts.ca = opts.ca || []
  opts.ca.push fs.readFileSync config.crowd.sslRootCertificate

server = ldapjs.createServer()
backend = ldapjsCrowd.createBackend
  crowd:
    url: config.crowd.url
    applicationName: config.crowd.applicationName
    applicationPassword: config.crowd.applicationPassword
  ldap:
    uid: config.ldap.uid
    dnSuffix: config.ldap.dnSuffix
    bindDn: config.ldap.bindDn
    bindPassword: config.ldap.bindPassword
    searchBase: config.ldap.searchBase
server.bind config.ldap.dnSuffix, backend.bind()
server.search config.ldap.dnSuffix, backend.search()

Q()
  .then ->
    Q.ninvoke server, 'listen', config.ldap.port
  .then ->
    console.log 'LDAP server listening at %s', server.url
