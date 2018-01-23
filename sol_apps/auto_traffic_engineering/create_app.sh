echo '<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright 2016 Open Networking Laboratory
  ~
  ~ Licensed under the Apache License, Version 2.0 (the "License");
  ~ you may not use this file except in compliance with the License.
  ~ You may obtain a copy of the License at
  ~
  ~     http://www.apache.org/licenses/LICENSE-2.0
  ~
  ~ Unless required by applicable law or agreed to in writing, software
  ~ distributed under the License is distributed on an "AS IS" BASIS,
  ~ WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  ~ See the License for the specific language governing permissions and
  ~ limitations under the License.
  -->
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>edu.unc</groupId>
    <artifactId>sol-te-app'$1'</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>bundle</packaging>

    <description>ONOS OSGi bundle archetype</description>
    <url>http://onosproject.org</url>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <onos.version>1.6.0</onos.version>
        <onos.app.name>TEApp'$1'</onos.app.name>
        <onos.app.title>Sample traffic engineering application using SOL</onos.app.title>
        <onos.app.origin>UNC</onos.app.origin>
        <onos.app.category>Utility</onos.app.category>
        <onos.app.requires>edu.unc.sol</onos.app.requires>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.onosproject</groupId>
            <artifactId>onos-api</artifactId>
            <version>${onos.version}</version>
        </dependency>

        <dependency>
            <groupId>org.onosproject</groupId>
            <artifactId>onlab-osgi</artifactId>
            <version>${onos.version}</version>
        </dependency>

        <dependency>
            <groupId>org.onosproject</groupId>
            <artifactId>onos-api</artifactId>
            <version>${onos.version}</version>
            <scope>test</scope>
            <classifier>tests</classifier>
        </dependency>

        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.10</version>
            <scope>test</scope>
        </dependency>

        <dependency>
            <groupId>org.apache.felix</groupId>
            <artifactId>org.apache.felix.scr.annotations</artifactId>
            <version>1.9.12</version>
            <scope>provided</scope>
        </dependency>

        <dependency>
            <groupId>edu.unc</groupId>
            <artifactId>sol</artifactId>
            <version>1.1</version>
            <scope>provided</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.felix</groupId>
                <artifactId>maven-bundle-plugin</artifactId>
                <version>3.0.1</version>
                <extensions>true</extensions>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>2.5.1</version>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.felix</groupId>
                <artifactId>maven-scr-plugin</artifactId>
                <version>1.21.0</version>
                <executions>
                    <execution>
                        <id>generate-scr-srcdescriptor</id>
                        <goals>
                            <goal>scr</goal>
                        </goals>
                    </execution>
                </executions>
                <configuration>
                    <supportedProjectTypes>
                        <supportedProjectType>bundle</supportedProjectType>
                        <supportedProjectType>war</supportedProjectType>
                    </supportedProjectTypes>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.onosproject</groupId>
                <artifactId>onos-maven-plugin</artifactId>
                <version>1.10</version>
                <executions>
                    <execution>
                        <id>cfg</id>
                        <phase>generate-resources</phase>
                        <goals>
                            <goal>cfg</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>swagger</id>
                        <phase>generate-sources</phase>
                        <goals>
                            <goal>swagger</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>app</id>
                        <phase>package</phase>
                        <goals>
                            <goal>app</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>

</project>' > 'pom.xml'


echo '/*
 * Copyright 2016-present Open Networking Laboratory
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package edu.unc.te;
// SOL imports
import edu.unc.sol.app.*;
import edu.unc.sol.service.SolService;
// Annotation imports
import org.apache.felix.scr.annotations.*;
// ONLAB imports
import org.onlab.packet.EthType.EtherType;
import org.onlab.packet.IpPrefix;
// ONOSPROJECT imports
import org.onosproject.core.ApplicationId;
import org.onosproject.core.CoreService;
import org.onosproject.net.Device;
import org.onosproject.net.device.DeviceService;
import org.onosproject.net.flow.DefaultTrafficSelector;
import org.onosproject.net.flow.TrafficSelector;
import org.onosproject.net.intent.IntentService;
import org.onosproject.net.topology.Topology;
import org.onosproject.net.topology.TopologyService;
// Logger imports
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
// Java imports
import java.util.*;
import java.lang.Integer;
// Constraint Metric imports
import static edu.unc.sol.app.Constraint.*;

@Component(immediate = true)
public class TrafficEngineeringApp {

    private final Logger log = LoggerFactory.getLogger(getClass());
    @Reference(cardinality = ReferenceCardinality.MANDATORY_UNARY)
    private CoreService core;
    @Reference(cardinality = ReferenceCardinality.MANDATORY_UNARY)
    private SolService sol;
    @Reference(cardinality = ReferenceCardinality.MANDATORY_UNARY)
    private IntentService intentService;
    @Reference(cardinality = ReferenceCardinality.MANDATORY_UNARY)
    private TopologyService topologyService;
    @Reference(cardinality = ReferenceCardinality.MANDATORY_UNARY)
    private DeviceService deviceService;

    private ApplicationId appid;

        // Creating TCs so that all Hosts can send traffic to all other Hosts
    private List<TrafficClass> makeRandomTrafficClasses() {
        Topology t = topologyService.currentTopology();
        List<Device> devices = new ArrayList<Device>();
        deviceService.getAvailableDevices().forEach(devices::add);

	// random number generator for volumes
	Random rand = new Random();
	
	int prefix = 167772161; // 10.0.0.1
	List<TrafficClass> result = new ArrayList<>();
	HashMap<Device, IpPrefix> ips = new HashMap<>();

	// parse the device ID number
	for (Device d : devices) {
	    int device_num = Integer.parseInt(d.id().toString().substring(3), 16) - 1; //zero-index
	    ips.put(d,IpPrefix.valueOf(prefix+device_num,32));
	}

	// create traffic classes for each pair of devices (for half of the devices)
	int size = devices.size();
	// shuffle the devices 
	Collections.shuffle(devices);
	int cnt1 = 0;
	int cnt2 = 0;
	for (Device src : devices) {
	    if (cnt1 >= size) {
		break;
	    }
	    cnt1++;
	    cnt2 = 0;
	    for (Device dst : devices) {
		if (cnt2 >= size) {
		    break;
		}
		cnt2++;
		if (src.equals(dst)) {
		    continue;
		}
		TrafficSelector.Builder tcbuilder = DefaultTrafficSelector.builder();
		tcbuilder.matchEthType(EtherType.IPV4.ethType().toShort());
		tcbuilder.matchIPSrc(ips.get(src));
		tcbuilder.matchIPDst(ips.get(dst));
		result.add(new TrafficClass(tcbuilder.build(),
					    src.id(), dst.id(), rand.nextInt(1 << 4)));
	    }
	}
        return result;
    }

    
    // Creating TCs so that all Hosts can send traffic to all other Hosts
    private List<TrafficClass> makeTrafficClasses() {
        Topology t = topologyService.currentTopology();
        List<Device> devices = new ArrayList<Device>();
        deviceService.getAvailableDevices().forEach(devices::add);

	int prefix = 167772161; // 10.0.0.1
	List<TrafficClass> result = new ArrayList<>();
	HashMap<Device, IpPrefix> ips = new HashMap<>();

	// parse the device ID number
	for (Device d : devices) {
	    int device_num = Integer.parseInt(d.id().toString().substring(3), 16) - 1; //zero-index
	    ips.put(d,IpPrefix.valueOf(prefix+device_num,32));
	}

	// create traffic classes for each pair of devices
	for (Device src : devices) {
	    for (Device dst : devices) {
		if (src.equals(dst)) {
		    continue;
		}
		TrafficSelector.Builder tcbuilder = DefaultTrafficSelector.builder();
		tcbuilder.matchEthType(EtherType.IPV4.ethType().toShort());
		tcbuilder.matchIPSrc(ips.get(src));
		tcbuilder.matchIPDst(ips.get(dst));
		result.add(new TrafficClass(tcbuilder.build(),
					    src.id(), dst.id(), 1 << 4));
	    }
	}
        return result;
    }

    /**
     * Create the constraint set for our app.
     *
     * @return
     */
    private List<Constraint> getConstraints() {
        // Empty set first
        List s = new ArrayList();
        // Add constraints one by one
        s.add(edu.unc.sol.app.Constraint.ALLOCATE_FLOW);
        s.add(edu.unc.sol.app.Constraint.ROUTE_ALL);
        return s;
    }

    private Objective getObjective() {
        return new Objective(edu.unc.sol.app.ObjectiveName.OBJ_MIN_LINK_LOAD, edu.unc.sol.app.Resource.BANDWIDTH);
    }


    @Activate
    protected void activate() {
	// register the application with the core service
        appid = core.registerApplication("TEApp'$1'");
        HashMap<Resource, Double> costs = new HashMap<>();
        costs.put(Resource.BANDWIDTH, 1.0);
	// register the application with SOL
        sol.registerApp(appid, makeRandomTrafficClasses(),
                new Optimization(getConstraints(), getObjective(), costs),
			paths -> paths.forEach(p -> intentService.submit(p)), "null_predicate", null);
        log.info("TE app started");
    }

    @Deactivate
    protected void deactivate() {
	// unregister the application with SOL
        sol.unregisterApp(appid);
        log.info("TE app stopped");
    }

}
' > 'src/main/java/edu/unc/te/TrafficEngineeringApp.java'

mvn clean install
#./onos-app 10.0.2.15 install target/sol-te-app$1-1.0-SNAPSHOT.oar
