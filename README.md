# snort2-with-openappid-docker
Dockerfile of snort2 with openappid

## 组件及版本

|组件|版本|
|:---|:--|
|snort|2.9.11.1|
|daq|2.0.6|
|openappid|8373|
|rules|community|

## 使用方法

### 获取镜像

```
$ docker pull traceflight/snort2-with-openappid-docker
```

### 监听主机网卡

首先获取待监听网卡名称：

```
$ ip a
```

使用docker的host模式监听指定网卡（假设为eth0），挂载本地路径（`/var/log/snort`）存放日志信息：

```
$ docker run -it --name snort --net=host \
    --cap-add=NET_ADMIN \
    -v /var/log/snort/:/var/log/snort/ \
    traceflight/snort2-with-openappid-docker \
    snort -c /etc/snort/snort.conf \
    -i eth0
```

### 分析Pcap数据

运行snort并挂载待分析文件

```
$ docker run -it --rm -v path/to/pcapdir:/data \
    traceflight/snort2-with-openappid-docker /bin/bash
```

分析数据
```
$ snort -c /etc/snort/snort.conf -r /data/pcapfile.pcap 
```

## 自定义应用检测器

可使用自带的appid_detector_builder.sh脚本生成自定义检测器。

将自定义检测脚本放置在`custom/lua`文件夹中，然后重新挂载`custom`文件夹到`/etc/snort/appid/`文件夹中。

## 使用中可能出现错误提示

**ERROR: Cannot decode data link type 113**

原因：libpcap在对Linux进行抓包时，若对any接口进行抓包，使用的格式为[Linux cooked-mode capture (SLL)](https://wiki.wireshark.org/SLL)，snort不支持该格式。

解决方法：不对any接口进行抓包，对指定接口如eth0抓包即可。

**SIOETHTOOL(ETHTOOL_GUFO) ioctl failed: Operation not permitted**

原因：容器对监听本地网卡的权限不足。

解决方法：在docker运行时，添加参数`--cap-add=NET_ADMIN`。
