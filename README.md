cloud_server_analytics
======================

1. Sample instance repose looks like

{"item" =>
     [{"instanceId" => "i-7b0b0c18",
       "imageId" => "ami-06ad526f",
       "instanceState" => {"code" => "80", "name" => "stopped"},
       "privateDnsName" => nil,
       "dnsName" => nil,
       "reason" => "User initiated (2011-12-31 17:26:45 GMT)",
       "keyName" => "sandbox",
       "amiLaunchIndex" => "0",
       "productCodes" => nil,
       "instanceType" => "t1.micro",
       "launchTime" => "2011-12-05T18:14:42.000Z",
       "placement" => {"availabilityZone" => "us-east-1a", "groupName" => nil},
       "kernelId" => "aki-407d9529",
       "monitoring" => {"state" => "disabled"},
       "stateReason" => {"code" => "Client.UserInitiatedShutdown", "message" => "Client.UserInitiatedShutdown: User initiated shutdown"},
       "architecture" => "i386",
       "rootDeviceType" => "ebs",
       "rootDeviceName" => "/dev/sda1",
       "blockDeviceMapping" =>
           {"item" => [
               {"deviceName" => "/dev/sda1",
                "ebs" => {"volumeId" => "vol-8578c3e8", "status" => "attached", "attachTime" => "2011-12-31T17:27:20.000Z", "deleteOnTermination" => "true"}
               },
               {"deviceName" => "/dev/sdm",
                "ebs" => {"volumeId" => "vol-8b78c3e6", "status" => "attached", "attachTime" => "2011-12-31T17:27:20.000Z", "deleteOnTermination" => "true"}
               }]
           },
       "virtualizationType" => "paravirtual",
       "clientToken" => nil,
       "tagSet" =>
           {"item" => [
               {"key" => "inscitiv:task-message", "value" => "Bootstrapped core packages"},
               {"key" => "inscitiv:task-name", "value" => "corePackages"},
               {"key" => "inscitiv:organization", "value" => "inscitiv_dev"},
               {"key" => "inscitiv:status", "value" => "running"},
               {"key" => "inscitiv:task-error-code", "value" => nil},
               {"key" => "inscitiv:owner", "value" => "kgilpin"},
               {"key" => "Name", "value" => "Workspace DB Server"}
           ]}
      }
     ]
}