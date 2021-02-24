# GlusterFS test Vagrant environment

A Vagrant and VirtualBox virtual machine environment to test a GlusterFS storage cluster.
Useful for playing around with GlusterFS in a sandbox.

Vagrant provisioning creates Ubuntu 20.04 servers, installs GlusterFS 9, and partitions XFS disks ready for use by GlusterFS.
Creation of volume and setting up a mount on a test client is a manual step after servers are ready.

Features:

* Replica 3 setup, for high availability and to avoid split-brain.
* Separate disks for storage data.
* Servers communicate with eachother using the VirtualBox internal network.

Servers:

* `dev-gluster-{01,02,03}` for the storage cluster itself.
* `dev-client-01` for testing GlusterFS mount.

## Usage

Assuming Vagrant and VirtualBox are already installed:

```
vagrant up
```

Set up the storage cluster:

```
vagrant ssh dev-gluster-01
sudo -i
gluster peer probe 192.168.10.20
gluster peer probe 192.168.10.30
gluster volume create gv0 replica 3 192.168.10.{10,20,30}:/mnt/data/gv0
gluster volume start gv0
```

`gv0` is now ready to be mounted!

Set up a test client to mount the volume:

```
vagrant ssh dev-client-01
sudo -i
mkdir -p /mnt/gv0
echo "192.168.10.10:/gv0 /mnt/gv0 glusterfs defaults,_netdev,backup-volfile-servers=192.168.10.20:192.168.10.30 0 0" >> /etc/fstab
mount /mnt/gv0
```

`/mnt/gv0` is now ready to be used!

## Resizing volume

Increase the `data` disk sizes in `Vagrantfile` to whatever you want, then:

```
vagrant reload dev-gluster-01 dev-gluster-02 dev-gluster-03
vagrant ssh dev-gluster-01 -c 'xfs_growfs /mnt/data'
vagrant ssh dev-gluster-02 -c 'xfs_growfs /mnt/data'
vagrant ssh dev-gluster-03 -c 'xfs_growfs /mnt/data'
```

## Performance testing/tuning

For testing, I use the [`smallfile`](https://github.com/distributed-system-analysis/smallfile) benchmark tool.
Although your storage use case will vary, e.g. size of files you'll be storing on the cluster, so you may wish to use another benchmark like fio.

These options may improve small file performance:

```
gluster volume set gv0 group metadata-cache
gluster volume set gv0 performance.qr-cache-timeout 600
gluster volume set gv0 performance.readdir-ahead on
gluster volume set gv0 performance.parallel-readdir on
```

NOTE: I tried `nl-cache`, but found file/dir not found errors during benchmarking, so I left those off. In any
case, it's always a good idea to test after enabling options!


You can also have clients use more threads, which you'll want to adjust according to `glusterfs` processes with `netstat -ntp | grep glusterfs` on clients:

```
gluster volume set gv0 client.event-threads 4
```

...and use a bigger cache on clients than the default 32MB, which you'll want to adjust according to memory available:

```
gluster volume set gv0 cache-size 512MB
```

References:

* [Gluster performance tuning docs](https://docs.gluster.org/en/latest/Administrator-Guide/Performance-Tuning/).
* [Small File Performance Enhancements docs)](https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.1/html/administration_guide/small_file_performance_enhancements).
* [Performance testing docs](https://docs.gluster.org/en/latest/Administrator-Guide/Performance-Testing/).
