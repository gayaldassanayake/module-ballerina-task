// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/test;

service noResourceService = service {};

Person person = {name: "Sam", age: 29};

//@test:Config {enable : false}
public function testForNoResourceService() {
    var attachResult = timerForNoResourceService.attach(noResourceService, person);
    test:assertTrue(attachResult is error);
    test:assertEquals(attachResult.toString(), "error SchedulerError (\"Failed to attach the service to the " +
        "scheduler\")");
}

service moreThanOneResourceService = service {
    resource function onTrigger() {}

    resource function onError(error e) {}
};

//@test:Config {enable : false}
public function testForMoreThanOneResource() {
    var attachResult = timerForNoResourceService.attach(moreThanOneResourceService, person);
    test:assertTrue(attachResult is error);
    test:assertEquals(attachResult.toString(), "error SchedulerError (\"Failed to attach the service to " +
        "the scheduler\")");
}
