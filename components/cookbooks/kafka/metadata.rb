name             "Kafka"
maintainer       "Messaging Team"
maintainer_email "GECMSGDE54@email.wal-mart.com"
license          "All rights reserved"
description	 "Install/Configure kafka"
version          "0.0.1"
description      "Kafka is a distributed, partitioned, replicated commit log service."

grouping 'default',
  :access => "global",
  :packages => [ 'base', 'mgmt.catalog', 'mgmt.manifest', 'catalog', 'manifest', 'bom' ]

# installation attributes
attribute 'version',
  :description          => 'Kafka version',
  :required => "required",
  :default               => '0.10.2.0',
  :format => {
    :important => true,
    :category => '1.Global',
    :help => 'Version of kafka',
    :order => 1,
    :form => {'field' => 'select', 'options_for_select' => [['0.10.2.0', '0.10.2.0'],['1.0.0', '1.0.0'],['1.1.1-beta', '1.1.1']]}
  }

attribute 'use_external_zookeeper',
  :description => "Use External Zookeeper",
  :default => 'false',
  :format => {
    :category => '1.Global',
    :help => 'Check this box only if want to use external Zookeeper',
    :order => 2,
    :form => {'field' => 'checkbox'}
}

attribute 'external_zk_url',
  :description          => 'External Zookeeper hosts (assume port 9091)',
  :default               => '',
  :format => {
    :category => '1.Global',
    :filter => {'all' => {'visible' => 'use_external_zookeeper:eq:true'}},
    :help => 'The comma-separated external ZooKeeper hosts. Assume port is 9091. Suggest to use hostname/fqdn here',
    :order => 3
}

attribute 'zk_quorum_size',
  :description          => 'Zookeeper Ensemble size',
  :default               => '3',
  :format => {
    :category => '1.Global',
    :filter => {'all' => {'visible' => 'use_external_zookeeper:eq:false'}},
    :help => 'The number of Kafka broker nodes that run Zookeeper electors. The rest of Kafka broker nodes runs Zookeeper observers',
    :order => 4,
    :form => {'field' => 'select', 'options_for_select' => [['3', '3'], ['5', '5']]}
}


attribute 'is_zk_secured',
  :description => "Is ZooKeeper Secured",
  :default => 'false',
  :format => {
    :category => '1.Global',
    :filter => {'all' => {'visible' => 'use_external_zookeeper:eq:true && version:neq:0.8.2.1'}},
    :help => 'Check this box only if your ZooKeeper is Secured or SASL enabled',
    :order => 5,
    :form => {'field' => 'checkbox'}
}

attribute 'zk_sasl_admin_password',
  :description          => 'Zookeeper SASL "admin" password',
  :default               => '',
  :encrypted => true,
  :format => {
    :category => '1.Global',
    :filter => {'all' => {'visible' => 'is_zk_secured:eq:true'}},
    :help => 'Password of the "admin" user for sasl/plain in Zookeeper',
    :order => 6
}


attribute 'kafka_server_log_retention_bytes',
  :description          => 'Kafka Log4j retention in MB',
  :required => "required",
  :default               => '1000',
  :format => {
    :category => '1.Global',
    :help => 'Megabytes of Kafka Log4j logs to retain',
    :order => 7,
    :pattern => "[0-9]+"
}

attribute 'restart_flavor',
  :description          => 'Restart Flavor',
  :required => "required",
  :default  => 'no',
  :format => {
    :category => '1.Global',
    :help => 'How do you want Kafka restart upon config/binary changes',
    :order => 8,
    :form => {'field' => 'select', 'options_for_select' => [['Rolling Restart (slow, no interruption)', 'rolling'], ['No Restart', 'no']]}
}

attribute 'rolling_restart_max_tries',
  :description          => 'Broker Rolling Restart: Maximum retries',
  :required => "required",
  :default               => '100',
  :format => {
    :category => '1.Global',
    :help => 'Timeout = rolling_restart_max_tries * rolling_restart_sleep_time. If Kafka holds large amount of data, increase this number to give more tolerance (time) of rolling restart',
    :order => 9,
    :filter => {'all' => {'visible' => 'restart_flavor:eq:rolling'}},
    :pattern => "[0-9]+"
}

attribute 'rolling_restart_sleep_time',
  :description          => 'Broker Rolling Restart: Sleep time in sec of each retry',
  :required => "required",
  :default               => '30',
  :format => {
    :category => '1.Global',
    :help => 'Timeout = rolling_restart_max_tries * rolling_restart_sleep_time. If Kafka holds large amount of data, increase this number to give more tolerance (time) of rolling restart',
    :order => 10,
    :filter => {'all' => {'visible' => 'restart_flavor:eq:rolling'}},
    :pattern => "[0-9]+"
}

 attribute 'jvm_args',
  :description          => 'JVM heap params in MB',
  :required => 'optional',
  :default               => '',
  :format => {
    :category => '1.Global',
    :help => 'JVM param specification in MB e.g. 1024',
    :order => 11,
    :pattern => "[0-9]+"
  }

attribute 'show_kafka_properties',
  :description => "Show Kafka broker properties",
  :default => 'false',
  :format => {
    :category => '2.Kafka Configuration Parameters',
    :help => 'Check this box only if you want to view or change the Kafka broker properties',
    :order => 1,
    :form => {'field' => 'checkbox'}
}

attribute 'kafka_properties',
    :description => "Customimze server.proerties for Kafka configuration",
    :data_type => "hash",
    :default => '{"delete.topic.enable":"true","auto.create.topics.enable":"true","unclean.leader.election.enable":"false","controlled.shutdown.enable":"true","controlled.shutdown.max.retries":"3","controlled.shutdown.retry.backoff.ms":"5000","default.replication.factor":"1","offsets.topic.num.partitions":"200","offsets.topic.replication.factor":"3","offsets.retention.check.interval.ms":"600000","offsets.topic.replication.factor":"3","offsets.commit.timeout.ms":"5000","num.network.threads":"3","num.replica.fetchers":"2","num.io.threads":"8","socket.send.buffer.bytes":"8388608","socket.receive.buffer.bytes":"8388608","socket.request.max.bytes":"104857600","log.retention.hours":"4","log.retention.bytes":"10737418240","log.segment.bytes":"536870912","log.segment.bytes":"536870912","log.cleanup.policy":"delete","zookeeper.connection.timeout.ms":"10000","zookeeper.session.timeout.ms":"10000","zookeeper.sync.time.ms":"2000","queued.max.requests":"500","replica.lag.time.max":"10000","replica.fetch.wait.max.ms":"500","min.insync.replicas":"2","replica.fetch.max.bytes":"2097152","message.max.bytes":"2097152","replica.high.watermark.checkpoint.interval.ms":"5000","replica.socket.timeout.ms":"30000","replica.socket.receive.buffer.bytes":"65536","log.flush.interval.ms":"5000"}',
    :format => {
        :important => true,
        :help => 'Customize Kafka config. Add new config if needed',
        :filter => {'all' => {'visible' => 'show_kafka_properties:eq:true'}},
        :category => '2.Kafka Configuration Parameters',
        :order => 2
}
attribute 'enable_rack_awareness',
    :description => "Enable Kafka Rack Awareness",
    :default => 'false',
    :format => {
        :category => '2.Kafka Configuration Parameters',
        :help => 'Check this box to enable Kafka Rack Awareness functionality. ignored with versions prior to 10.x',
        :order => 3,
        :form => {'field' => 'checkbox'},
        :filter => {'all' => {'visible' => 'version:neq:0.8.2.1'}}
    }

attribute 'show_zk_properties',
    :description => "Show Zookeeper properties",
    :default => 'false',
    :format => {
        :category => '3.Zookeeper Configuration Parameters',
        :help => 'Check this box only if you want to view or change the Zookeeper related properties',
        :order => 1,
        :form => {'field' => 'checkbox'}
}

attribute 'zookeeper_properties',
:description => "Customimze zookeeper.properties for Zookeeper configuration",
:data_type => "hash",
:default => '{"clientPort":"9091","tickTime":"2000","initLimit":"10","syncLimit":"5","maxClientCnxns":"1000","maxSessionTimeout":"180000","autopurge.snapRetainCount":"3","autopurge.purgeInterval":"1"}',
:format => {
    :important => true,
    :help => 'Customize Zookeeper config. Add new config if needed',
    :filter => {'all' => {'visible' => 'show_zk_properties:eq:true'}},
    :category => '3.Zookeeper Configuration Parameters',
    :order => 2
}

attribute 'monitoring_system',
    :description => 'Monitoring System',
    :default => 'false',
    :required => 'required',
    :format => {
        :category => '4.Monitoring',
        :help => 'Enable Graphite Monitoring',
        :form => {'field' => 'checkbox'},
        :order => 1,
}

attribute 'graphite_url',
    :description => 'Graphite URL (address:port)',
    :default => '# external_graphite_address:port, such as 10.1.2.3:2003 or www.graphite.com:2003 #',
    :format => {
        :help => 'External Graphite URL. A Graphtie cluster needs to be deployed and ready to use at this moment',
        :category => '4.Monitoring',
        :filter => {'all' => {'visible' => 'monitoring_system:eq:true'}},
        :order => 2
}

attribute 'enable_ssl',
          :description => 'Enable SSL',
          :default => 'false',
          :format => {
              :category => '5.SSL Configuration',
              :help => 'Enable SSL',
              :order => 1,
              :form => {'field' => 'checkbox'},
              :filter => {'all' => {'visible' => 'version:neq:0.8.2.1'}}
          }

attribute 'truststore_password',
          :description => 'Truststore password',
          :encrypted => true,
          :default => '',
          :format => {
              :category => '5.SSL Configuration',
              :help => 'Truststore password',
              :order => 2,
              :filter => {'all' => {'visible' => 'enable_ssl:eq:true'}}
         }

attribute 'ca_cert',
          :description => 'CA Certificate',
          :data_type => 'text',
          :default => '',
          :format => {
              :help => 'Enter the CA certificate content to be used (ca-cert file content)',
              :category => '5.SSL Configuration',
              :order => 3,
              :filter => {'all' => {'visible' => 'false'}}
          }

attribute 'ca_key',
          :description => 'CA Certificate Key',
          :data_type => 'text',
          :encrypted => true,
          :default => '',
          :format => {
              :help => 'Enter the CA certificate key content (ca-key file content)',
              :category => '5.SSL Configuration',
              :order => 4,
              :filter => {'all' => {'visible' => 'false'}}
          }

attribute 'ca_passphrase',
          :description => 'CA Passphrase',
          :encrypted => true,
          :default => '',
          :format => {
              :help => 'Enter the passphrase for the CA certificate key',
              :category => '5.SSL Configuration',
              :order => 5,
              :filter => {'all' => {'visible' => 'false'}}
          }

attribute 'disable_plaintext',
          :description => 'Disable Plain Text',
          :default => 'false',
          :format => {
              :category => '5.SSL Configuration',
              :help => 'Disable Plain Text. If true: all inter broker communication is through SSL',
              :order => 6,
              :form => {'field' => 'checkbox'},
              :filter => {'all' => {'visible' => 'enable_ssl:eq:true && version:neq:0.8.2.1'}}
          }

attribute 'enable_inter_broker_ssl',
          :description => 'Enable inter broker SSL',
          :default => 'false',
          :format => {
              :category => '5.SSL Configuration',
              :help => 'Enable inter broker SSL',
              :order => 7,
              :form => {'field' => 'checkbox'},
              :filter => {'all' => {'visible' => 'false' }}
          }

attribute 'enable_client_auth',
          :description => 'Enable Client Auth',
          :default => 'false',
          :format => {
              :category => '5.SSL Configuration',
              :help => 'Enable Client Auth',
              :order => 8,
              :form => {'field' => 'checkbox'},
              :filter => {'all' => {'visible' => 'enable_ssl:eq:true && version:neq:0.8.2.1'}}
          }

attribute 'enable_acl',
          :description => 'Enable ACL',
          :default => 'false',
          :format => {
              :category => '5.SSL Configuration',
              :help => 'Enable ACL',
              :order => 9,
              :form => {'field' => 'checkbox'},
              :filter => {'all' => {'visible' => 'enable_ssl:eq:true && enable_client_auth:eq:true && version:neq:0.8.2.1'}}
          }

attribute 'acl_super_user',
          :description => 'Super user for ACL',
          :format => {
              :category => '5.SSL Configuration',
              :help => 'Starts with User: followed by the issuer of the client cert, e.g. User:CN=aCN,OU=anOU,O=anO,L=aL,ST=aST,C=aCA',
              :order => 10,
              :filter => {'all' => {'visible' => 'enable_ssl:eq:true && enable_acl:eq:true && enable_client_auth:eq:true && version:neq:0.8.2.1'}}
          }

attribute 'enable_sasl_plain',
          :description => 'Enable SASL/Plain',
          :default => 'false',
          :format => {
              :category => '6.SASL/Plain Configuration',
              :help => 'Enable SASL/Plain to use username/password for kafka connections',
              :order => 1,
              :form => {'field' => 'checkbox'},
              :filter => {'all' => {'visible' => 'enable_ssl:eq:false && version:neq:0.8.2.1'}}
          }

attribute 'sasl_admin_pwd',
          :description => 'Password for sasl/plain admin user',
          :encrypted => true,
          :default => 'W3Rsaf3!',
          :format => {
              :help => 'Password of the admin user for sasl/plain',
              :category => '6.SASL/Plain Configuration',
              :order => 2,
              :filter => {'all' => {'visible' => 'enable_sasl_plain:eq:true'}}
          }

attribute 'sasl_user_pwds',
          :description => 'Username and password for sasl/plain clients',
          :data_type => "hash",
          :default => nil,
          :format => {
              :category => '6.SASL/Plain Configuration',
              :help => 'First field for user; second field for password',
              :order => 3,
              :filter => {'all' => {'visible' => 'enable_sasl_plain:eq:true'}}
          }

attribute 'cloud_index_mapping',
    :description => "Mapping for cloud indices; maps a cloud number to an index number",
    :data_type => "hash",
    :default => nil,
    :format => {
        :help => 'Mapping for cloud indices; maps a cloud number to an index number; updated during kafka deployment',
        :filter => {'all' => {'visible' => 'false'}},
        :category => '7.Kafka Deployment Time Mapping Data',
        :order => 1
    }

attribute 'client_certs',
    :description => "Client Certificate location",
    :data_type => "array",
    :format => {
      :help => 'Client Truststore location. eg.certlocation',
      :category => '8.Client Certs Management.',
      :order => 1
}
recipe "status", "Kafka Status"
recipe "start", "Start Kafka"
recipe "stop", "Stop Kafka"
recipe "restart", "Restart Kafka"
recipe "startjmxtrans", "Start Jmxtrans"
recipe "stopjmxtrans", "Stop Jmxtrans"
recipe "restartjmxtrans", "Restart Jmxtrans"
