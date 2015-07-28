Q = require 'q'
ldapjs = require 'ldapjs'
ldapjsCrowd = require 'ldapjs-crowd'
fs = require 'fs'

configFile = process.argv[2]
configJson = fs.readFileSync configFile
config = JSON.parse configJson

server = ldapjs.createServer()
backend = ldapjsCrowd.createBackend
  crowd:
    url: config.crowd.url
    applicationName: config.crowd.applicationName
    applicationPassword: config.crowd.applicationPassword
  ldap:
    dnSuffix: config.ldap.dnSuffix
    bindDn: config.ldap.bindDn
    bindPassword: config.ldap.bindPassword
    searchBase: config.ldap.searchBase
server.add config.ldap.dnSuffix, backend.add
server.modify config.ldap.dnSuffix, backend.modify
server.modifyDN config.ldap.dnSuffix, backend.modifyDN
server.bind config.ldap.dnSuffix, backend.bind
server.compare config.ldap.dnSuffix, backend.compare
server.del config.ldap.dnSuffix, backend.del
server.search config.ldap.dnSuffix, backend.search

Q()
  .then ->
    Q.ninvoke server, 'listen', config.ldap.port
  .then ->
    console.log 'LDAP server listening at %s', server.url
