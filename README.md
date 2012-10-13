# Installation
```
git clone git://github.com/falsecz/gummi-cli.git
```

make symlink to your bindir in path
```
ln -s $(pwd)/bin/gummi ~/bin/gummi
```

# Command

All commands must be executed inside git repository (registered in stack)

## Stop all processes
```
$ gummi ps:stop
All processes stopped
```

## Restart all processes
```
$ gummi ps:restart
	...
```


## List all processes
```
$ gummi ps
	[web-1] 3 minutes ago	 node web.js
	[web-2] 3 minutes ago	 node web.js
```


## Tail logs
```
$ gummi logs  #by default live tail

	2012-10-13 20:56:16.565 [dyno]  Starting container for web-2 node web.js
	2012-10-13 20:56:16.568 [dyno]  Starting container for web-1 node web.js
	2012-10-13 20:56:16.848 [web-2]  > Detecting platform
	2012-10-13 20:56:16.850 [web-2]  > Detected platform: Node.js
	2012-10-13 20:56:16.866 [web-1]  > Detecting platform
	2012-10-13 20:56:16.869 [web-1]  > Detected platform: Node.js
	2012-10-13 20:56:17.122 [web-2]  > Node.js buildpack v0.8.2 | npm@1.1.36 
	2012-10-13 20:56:17.138 [web-1]  > Node.js buildpack v0.8.2 | npm@1.1.36 
	2012-10-13 20:56:17.162 [web-2]  13 Oct 20:56:17 - process.env.GUMMI: BEAR
	2012-10-13 20:56:17.177 [web-1]  13 Oct 20:56:17 - process.env.GUMMI: BEAR
	2012-10-13 20:56:17.262 [web-2]  Startuju server....
	2012-10-13 20:56:17.269 [web-2]  Listening on 5000
	2012-10-13 20:56:17.277 [web-1]  Startuju server....
	2012-10-13 20:56:17.283 [web-1]  Listening on 5000
	2012-10-13 20:56:30.959 [web-2]  13 Oct 20:56:30 - Ola ola
```