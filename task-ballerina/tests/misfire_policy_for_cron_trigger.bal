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

import ballerina/lang.runtime as runtime;
import ballerina/test;

int triggeredCount6 = 0;

service object {} misfireService6 = service object {
    remote function onTrigger() {
        triggeredCount6 = triggeredCount6 + 1;
    }
};

@test:Config {
    groups: ["scheduler", "misfire"]
}
function testFireAndProceedWithService6() returns error? {
    Scheduler taskTimer = check new ({ cronExpression: "* * * * * ? *", noOfRecurrences: 8,
                                 misfirePolicy: "fireAndProceed"  });
    check taskTimer.attach(misfireService6);
    check taskTimer.start();
    runtime:sleep(1.5);
    int count = triggeredCount6;
    check taskTimer.pause();
    runtime:sleep(1);
    test:assertEquals(triggeredCount6, count, msg = "Expected count mismatched during the scheduler pause.");
    check taskTimer.resume();
    runtime:sleep(6);
    test:assertEquals(triggeredCount6, 8, msg = "Expected count mismatched.");
    check taskTimer.stop();
}

int triggeredCount7 = 0;

service object {} misfireService7 = service object {
    remote function onTrigger() {
        triggeredCount7 = triggeredCount7 + 1;
    }
};

@test:Config {
    groups: ["scheduler", "misfire"]
}
function testdoNothingWithService7() returns error? {
    Scheduler taskTimer = check new ({ cronExpression: "* * * * * ? *", noOfRecurrences: 5, misfirePolicy: "doNothing" });
    check taskTimer.attach(misfireService7);
    check taskTimer.start();
    runtime:sleep(1.5);
    int count = triggeredCount7;
    check taskTimer.pause();
    runtime:sleep(1);
    test:assertEquals(triggeredCount7, count, msg = "Expected count mismatched during the scheduler pause.");
    check taskTimer.resume();
    runtime:sleep(6);
    test:assertEquals(triggeredCount7, 5, msg = "Expected count mismatched");
    check taskTimer.stop();
}
