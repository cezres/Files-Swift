## Files

## 如何运行

#### 环境
Xcode 10.3   
node v12.9.0

```bash
# clone repo
$ git clone -b develop https://github.com/cezres/Files.git && cd Files/
$ git submodule update --init

# install pods
$ pod install

# build files-web
$ cd files-web/
$ yarn && yarn build

# build ijkplayer
$ cd ../ijkplayer/
$ ./init-ios.sh
$ cd ios
$ ./compile-ffmpeg.sh clean
$ ./compile-ffmpeg.sh all

# open Files.xcworkspace
```

## 截图

![](http://111.231.91.212/wp-content/uploads/2019/09/IMG_0859-139x300.png) | ![](http://111.231.91.212/wp-content/uploads/2019/09/IMG_0860-139x300.png) | ![](http://111.231.91.212/wp-content/uploads/2019/09/IMG_0861-139x300.png)
:-|:-|:-
![](http://111.231.91.212/wp-content/uploads/2019/09/IMG_0863-139x300.png) | ![](http://111.231.91.212/wp-content/uploads/2019/09/IMG_0880-139x300.png) | ![](http://111.231.91.212/wp-content/uploads/2019/09/IMG_0882-139x300.png)
![](http://111.231.91.212/wp-content/uploads/2019/09/IMG_0878-139x300.png)

![](http://111.231.91.212/wp-content/uploads/2019/09/IMG_0877-300x139.png)
![](http://111.231.91.212/wp-content/uploads/2019/09/屏幕快照2019-08-25下午6.29.11.png)
![](http://111.231.91.212/wp-content/uploads/2019/09/屏幕快照2019-08-25下午6.27.36.png)
