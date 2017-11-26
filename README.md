docker run -it -p 8888:8888 -v "$(pwd):/notebooks" koduki/image-search
$ docker run -it -v `pwd`:/app -p 4567:4567 koduki/image-searcher-app /bin/bash
ruby app.rb -o 0.0.0.0
