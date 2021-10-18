# Hadoop Spark Cluster

This project is based on the work of [avp38](https://github.com/avp38/Hadoop-Spark-Environment)

Its is to create a Hadoop/Spark Cluster in a VirtualBox Environment that can be interfaced using Jupyter Lab.

## Cluster Architecture

|VM|HDFS|YARN|Spark|JupyterLab|
|-|-|-|-|-|
|head|NameNode||Master||
|body||ResourceManager</br>JobHistoryServer</br>ProxyServer|||
|slave1|DataNode|NodeManager|Slave||
|slave2|DataNode|NodeManager|Slave||
|jupyter||||JupyterServer|

## Webinterfaces

|Service|URL|
|-|-|
|NameNode|http://localhost:50070/dfshealth.html|
|ResourceManager|http://localhost:18088/cluster|
|JobHistory|http://localhost:19888/jobhistory|
|Spark|http://localhost:8080|
|JupyterLab(optional)|http://localhost:54321|

# Setup Host

## Download

* [Ubuntu 20.04.03 Desktop](https://releases.ubuntu.com/20.04.3/ubuntu-20.04.3-desktop-amd64.iso?_ga=2.192166504.37755249.1634021994-306704312.1634021994)
* [VirtualBox 6.1.26](https://download.virtualbox.org/virtualbox/6.1.26/virtualbox-6.1_6.1.26-145957~Ubuntu~eoan_amd64.deb)

## Install

### Ubuntu

Create an USB-Stick with [Rufus (Win)](https://rufus.ie/en/), or the Ubuntu Disk Creator tool and install Ubuntu Desktop

### Git

    $ sudo apt install git-all

### Docker

    $ sudo apt update
    $ sudo apt install apt-transport-https ca-certificates curl software-properties-common
    $ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    $ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    $ apt-cache policy docker-ce
    $ sudo apt install docker-ce
    $ sudo systemctl status docker
    
Docker can be run by any user:  
    
    $ sudo usermod -aG docker ${USER}
    $ su - ${USER}
    $ groups
    $ sudo usermod -aG docker $USER
    
### Docker Compose

[Git](https://github.com/docker/compose/releases)

    $ sudo curl -L "https://github.com/docker/compose/releases/download/v2.0.1/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
    $ sudo chmod +x /usr/local/bin/docker-compose
    $ docker-compose --version
    
### VirtualBox

Install Package
    
### Vagrant

    $ curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    $ sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    $ sudo apt-get update && sudo apt-get install vagrant
    $ vagrant plugin install vagrant-vbguest

# Setup Cluster

    $ git clone https://github.com/datainsightat/hadoop_spark_cluster.git
    $ cd Hadoop-Spark-Environment/resources
    $ wget https://archive.apache.org/dist/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz
    $ wget http://d3kbcqa49mib13.cloudfront.net/spark-2.1.0-bin-hadoop2.7.tgz
    $ sudo vagrant up
    $ vagrant vbguest --do install
    
## Initialze Hadoop

(Apache Hadoop)[http://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/ClusterSetup.html]
(Apache Spark)[https://spark.apache.org/docs/latest/running-on-yarn.html]

    $ vagrant ssh head
    head $ hdfs namenode -format hadoop_cluster
 
## Start Hadoop
    
    $ vagrant ssh head
    
    head $ $HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start namenode
    head $ sshpass -p vagrant $HADOOP_PREFIX/sbin/hadoop-daemons.sh --config $HADOOP_CONF_DIR --script hdfs start datanode
    head $ jps
    
    $ vagrant ssh body
    
    body $ $HADOOP_YARN_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start resourcemanager
    body $ sshpass -p vagrant $HADOOP_YARN_HOME/sbin/yarn-daemons.sh --config $HADOOP_CONF_DIR start nodemanager
    body $ $HADOOP_YARN_HOME/sbin/yarn-daemon.sh start proxyserver --config $HADOOP_CONF_DIR
    body $ $HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh start historyserver --config $HADOOP_CONF_DIR
    body $ jps

## Test yarn

    body $ yarn jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar pi 2 100
    
## Start Spark

    $ vagrant ssh head
    head $ sshpass -p vagrant $SPARK_HOME/sbin/start-all.sh
    
## Test Spark

    head $ $SPARK_HOME/bin/spark-submit --class org.apache.spark.examples.SparkPi --master yarn --num-executors 10 --executor-cores 2 $SPARK_HOME/examples/jars/spark-examples*.jar 100
    
    head $ $SPARK_HOME/bin/spark-shell --master spark://head:7077
    
# Operate Cluster

## Start

    

## Stop

    $ cd PATH_TO_CLUSTER
    $ vagrant ssh head
    head $ sshpass -p vagrant $SPARK_HOME/sbin/stop-dfs.sh
    $ vagrant ssh body
    body $ sshpass -p vagrant $SPARK_HOME/sbin/stop-yarn.sh
    $ vagrant ssh head
    head $ sshpass -p vagrant $SPARK_HOME/sbin/stop-all.sh
    $ cd PATH_TO_CLUSTER
    $ sudp vagrant halt
    
# Update Hadoop, Spark

If you update the cluster to new versions of hadoop and spark, use these commands to start the cluster:

     body $ yarn --daemon start resourcemanager --config $HADOOP_CONF_DIR 
     body $ yarn --daemon start nodemanager --config $HADOOP_CONF_DIR 
     body $ yarn --daemon start proxyserver --config $HADOOP_CONF_DIR
     body $ yarn --daemon start timelineserver --config $HADOOP_CONF_DIR
     
     head $ hdfs --daemon start namenode --config $HADOOP_CONF_DIR
     head $ hdfs --daemon start datanode --config $HADOOP_CONF_DIR

# Setup Jupyter Lab (optional)

## Download

* [Ubuntu 20.04.03 Server](https://releases.ubuntu.com/20.04.3/ubuntu-20.04.3-desktop-amd64.iso?_ga=2.192166504.37755249.1634021994-306704312.1634021994)

Virtualbox: Settings > Network > Advanced > Port Forwarding > Host Port: 54321, GuestPort: 8888

## Install

    $ wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh
    $ sudo apt-get install libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6
    $ bash ~/Downloads/Anaconda3-2021.05-Linux-x86_64.sh
    $ vim .basrc
      export PATH=~/anaconda3/bin:$PATH
    $ source .bashrc
    $ conda create --name jupyterlab
    $ conda activate jupyterlab
    $ conda install -c r r r-essentials r-irkernel
    $ jupyter lab --generate-config
    $ vim ~/.jupyter/jupyter_lab_config.py
      c.ServerApp.token = ''
      c.NotebookApp.ip = '*'
      c.ServerApp.open_browser = False
    $ jupyter lab
