# Ruby1459

Ruby1459 is an IRC (Internet Relay Chat) library written in Ruby.  It's designed to be used as a client library.  Ruby1459 is object oriented and heavily event driven.  It's under current development and features are still being added regularly.

* [IRC Basics](#basics)
* [Library features](#features)
* [Example](#example)
* [Project status](#status)
* [API Reference](#api)

<a name="basics"></a>
## IRC Basics

IRC is a chat protocol originally developed in the late 80s but formalized in RFC 1459 in 1993.  Despite its age, it's still heavily used by countless people around the world.

IRC communication is passed in text format over a TCP socket usually on port 6667. Users are known on irc by their nickname and they join chat rooms, which are called channels.  Users can also directly message other users as long as the other user is online.

Moderators of a channel have symbols next to their nickname to denote the level of authority they hold.  Exact symbols used, and their meanings, can vary server to server.

<a name="features"></a>
# Library Features

## Object Oriented
The library is made of two primary classes, `IRCConnection` and `IRCChannel`.  Use is straight forward.  Create an instance of `IRCConnection` and then create `IRCChannel` instances using the IRCConnection instance.  As the library interacts with the server, the object will be updated to reflect new information and allows easy access.  Such as `channel.userlist` will always hold the current occupants of a channel.  An Object Oriented design is easy to grasp and makes sense in this context.

## Event Driven
Both IRCConnection and IRCChannel have a number of events to hook onto.  These include lifecycle events, such as `connecting` or `disconnected`.  Or user actions, such as: `user_join` or `new_topic`.

Additionally, every command from the server can be directly hooked onto if desired.  This allows greater flexibility to implement custom features that are not in the library's scope.  Any events directly from the server are always in 'UPPERCASE', whereas library generated events are in 'lowercase'.  A full list of these server generated events are found in the responses.rb file and in the IRC specifications.


## Multi-Threaded
The library will spin off a new thread for every IRC connection.  This lets the developer create as many connections as desired.

<a name="example"></a>
# Example

````ruby
#creates a new instance of IrcConnection
irc = IrcConnection.new({
  server: 'irc.freenode.net',
  nickname: 'alice'
  })

#hooks on to a library generated event
irc.on(:connection_err) do
  p "connection failed :("
end

#the tcp socket is established with the IRC server
irc.on(:connected) do
  p "connected!!"
end

#server has accepted the nickname given
#you are now ready to join channels and chat
irc.on(:registered) do

  #creates a new channel object for the channel '#freenode'
  chan = irc.createChannel('#freenode')

  #hooks onto the chanmsg event
  #will be fired whenever anyone speaks
  chan.on(:chanmsg) do |data|
    puts "#{data[:channel]} #{data[:user]}: #{data[:msg]}"
  end

  #finally joins the channel
  chan.join
end

#and finally connects to the irc server
irc.connect
````
The above snippet is a basic usage of the library.  First the connection object is created, then the appropriate events are hooked onto.  And lastly the connect method is invoked that actually connects to the server.  Events can be hooked onto, and channels can be joined, at any time. Even after the server is connected.

<a name="status"></a>
# Project Status

IRC is a sprawling protocol with decades of extensions and improvements.  Work is already underway for the 3rd major version of the protocol, IRCv3.  Furthermore, many major server networks have custom features and have idiosyncrasies that need to be accounted for and properly handled.  For these reasons this project will be a 'work-in-progress' for a while to come.  I've listed the currently implemented features and I also have a list of the next few features that will be added.

## Currently Implemented Features
* connecting to servers
* recording server MOTD
* joining and leaving channels
* sending and receiving channel messages
* sending and receiving private messages
* keeping track of joins/parts
* keeping track of channel topic
* alternative nicknames

## Next 5 Features
* nickserv support
* whois lookups
* graceful disconnect of servers
* channel operator commands
* server-pushed channel joins (ie: bouncers)

<a name="api"></a>
# API Reference

## IrcConnection

### Connection Lifecycle Events
|Event Name|Description
|---|---|
|:connecting|The library is starting to establish the TCP connection
|:connection_error|failed to establish a TCP connection
|:connected|TCP connection successful.  Will automatically attempt to register
|:registering|Library is starting the log-on procedures for the network
|:registered|The log-on procedures were completed. Ready to chat!
|:disconnected|Server has disconnected gracefully and library is idle

### Other Events
*** Note: raw server events are in CAPITAL letters and are emitted from IrcConnection.  See `responses.rb` for a full list ***

|Event Name|Description
|---|---|
|:raw|The raw lines received from the server without any parsing
|:query|A private message from another user
|:self_new_nickname|The nickname for the connection has changed
|:forced_chan_join|The IRC server forced the client into a channel

### Read-Write Properties
*** Note: These properties are only used during the connection process ***

|Property Name|Default Value|Description
|---|---|---|
|server||**Required** - the url of the server
|port|6667|the port to connect to
|password||the server password used to connect
|nickname||**Required** - the nickname will be used on the networks
|realname|"User Name"|The 'real' name reported to the server.  Not recommended to use your real name
|username|"user"|the username reported to the server

### Read-Only Properties
|Property Name|Description
|----|---|
|server_motd|the info message sent to every user when connecting
|channels|a hash of every IrcChannel associated with the connection

### Methods
|Method Name|Arguments|Description|
|---------|------------|------------|
|new| [options] |creates a new IrcConnection class.  Can take optional arguments hash.  See the R/W properties for a list.|
|connect||connects to the irc server|
|query|nickname, msg| sends the `msg` to the desired `nickname`|
|write|msg|sends a raw string over the TCP connection|
|disconnect||closes the connection|
|createChannel|name|creates an IrcConnection object for the desired channel `name`|
|deleteChannel|name|leaves the channel and disassociates the channel from the connection|


___
## IrcChannel
### Event Lists
|Event Name|Description
|----|---|
|:new_topic|fired whenever the channel topic is changed
|:chanmsg|channel recevied a new message from another user
|:userlist_changed| a user either joined or left the channel, or a nickname changed
|:chan_join| another user joined the channel
|:chan_part| a user left the channel

### Read-Only Properties
|Property Name|Description
|----|---|
|topic|the current channel topic
|userlist|an array of the current users of the channel
|status|current state of the channel. currently can be either :parted (not joined) or :active (joined and ready)

### Methods
|Method Name|Arguments|Description
|----|---|---|
|join||attempts to join the channel
|part||leaves the channel
|speak|msg|sends the `msg` to the channel
