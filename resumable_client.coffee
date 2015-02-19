############################################################################
#     Copyright (C) 2014 by Vaughn Iverson
#     fileCollection is free software released under the MIT/X11 license.
#     See included LICENSE file for details.
############################################################################

if Meteor.isClient

   # This is a polyfill for bind(), added to make phantomjs 1.9.7 work
   unless Function.prototype.bind
      Function.prototype.bind = (oThis) ->
         if typeof this isnt "function"
            # closest thing possible to the ECMAScript 5 internal IsCallable function
            throw new TypeError("Function.prototype.bind - what is trying to be bound is not callable")

         aArgs = Array.prototype.slice.call arguments, 1
         fToBind = this
         fNOP = () ->
         fBound = () ->
            func = if (this instanceof fNOP and oThis) then this else oThis
            return fToBind.apply(func, aArgs.concat(Array.prototype.slice.call(arguments)))

         fNOP.prototype = this.prototype
         fBound.prototype = new fNOP()
         return fBound

   share.setup_resumable = () ->
      url = "#{@baseURL}/_resumable"

      # export `ROOT_URL=<server hostname>` so that cordova knows where to connect to
      url = Meteor.absoluteUrl(url)  if Meteor.isCordova
      console.log(Meteor.absoluteUrl(url));

      r = new Resumable
         target: url
         generateUniqueIdentifier: (file) -> "#{new Meteor.Collection.ObjectID()}"
         fileParameterName: 'file'
         chunkSize: @chunkSize
         testChunks: true
         simultaneousUploads: 3
         maxFiles: undefined
         maxFilesErrorCallback: undefined
         prioritizeFirstAndLastChunk: false
         query: undefined
         headers: {}

      unless r.support
         console.error "resumable.js not supported by this Browser, uploads will be disabled"
         @resumable = null
      else
         @resumable = r
