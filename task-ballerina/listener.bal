// Copyright (c) 2019 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/jballerina.java;

# Represents a ballerina task listener, which can be used to schedule and execute tasks periodically.
public class Listener {

    boolean started = false;

    private TimerConfiguration|AppointmentConfiguration listenerConfiguration;

    # Initializes the `task:Listener` object. This may panic if the initialization is failed due to a configuration
    # error.
    #
    # + configuration - The `task:TimerConfiguration` or `task:AppointmentConfiguration` record to define the
    #                   `task:Listener` behavior
    public isolated function init(TimerConfiguration|AppointmentConfiguration configuration) returns ListenerError? {
        validateConfiguration(configuration);
        self.listenerConfiguration = configuration;
        return initExternal(self);
    }

    # Attaches the given `service` to the `task:Listener`. This may panic if the service attachment is fails.
    #
    # + s - Service to attach to the listener
    # + name - Name of the service
    # + return - () or else a `task:ListenerError` upon failure to attach the service
    public isolated function attach(service object {} s, string[]|string? name = ()) returns error? {
        // ignore param 'name'
        var result = attachExternal(self, s);
        if (result is error) {
            panic result;
        }
    }

    # Detaches the given `service` from the `task:Listener`.
    #
    # + s - Service to be detached from the listener
    # + return - () or else a `task:ListenerError` upon failure to detach the service
    public isolated function detach(service object {}  s) returns error? {
        return detachExternal(self, s);
    }

    # Starts dispatching the services attached to the `task:Listener`. This may panic if the service dispatching causes
    # any error.
    #
    # + return - () or else a `task:ListenerError` upon failure to start the listener
    public isolated function 'start() returns error? {
        var result = startExternal(self);
        if (result is error) {
            panic result;
        }
        lock {
            self.started = true;
        }
    }

    # Stops the `task:Listener` and the attached services gracefully. It will wait if there are any tasks still to be
    # completed. This may panic if the stopping causes any error.
    #
    # + return - () or else a `task:ListenerError` upon failure to stop the listener
    public isolated function gracefulStop() returns error? {
        var result = stopExternal(self);
        if (result is error) {
            panic result;
        }
        lock {
            self.started = false;
        }
    }

    # Stops the `task:Listener` and the attached services immediately. This will cancel any ongoing tasks. This may
    # panic if the stopping causes any error.
    #
    # + return - () or else a `task:ListenerError` upon failure to stop the listener
    public isolated function immediateStop() returns error? {
        var result = stopExternal(self);
        if (result is error) {
            panic result;
        }
        lock {
            self.started = false;
        }
    }

    isolated function isStarted() returns boolean {
        return self.started;
    }

    # Pauses the `task:Listener` and the attached services.
    #
    # + return - A `task:ListenerError` if an error occurred while pausing or else ()
    public isolated function pause() returns ListenerError? {
        return pauseExternal(self);
    }

    # Resumes a paused `task:Listener`. Calling this on an already-running `task:Listener` will not cause any error.
    #
    # + return -  A `task:ListenerError` if an error occurred while resuming or else ()
    public isolated function resume() returns ListenerError? {
        return resumeExternal(self);
    }
}

isolated function pauseExternal(Listener task) returns ListenerError? = @java:Method {
    name: "pause",
    'class: "org.ballerinalang.stdlib.task.actions.TaskActions"
} external;

isolated function resumeExternal(Listener task) returns ListenerError? = @java:Method {
    name: "resume",
    'class: "org.ballerinalang.stdlib.task.actions.TaskActions"
} external;

isolated function stopExternal(Listener task) returns ListenerError? = @java:Method {
    name: "stop",
    'class: "org.ballerinalang.stdlib.task.actions.TaskActions"
} external;

isolated function startExternal(Listener task) returns ListenerError? = @java:Method {
    name: "start",
    'class: "org.ballerinalang.stdlib.task.actions.TaskActions"
} external;

isolated function initExternal(Listener task) returns ListenerError? = @java:Method {
    name: "init",
    'class: "org.ballerinalang.stdlib.task.actions.TaskActions"
} external;

isolated function detachExternal(Listener task, service object {} attachedService)
                        returns ListenerError? = @java:Method {
    name: "detach",
    'class: "org.ballerinalang.stdlib.task.actions.TaskActions"
} external;

isolated function attachExternal(Listener task, service object {} s, any... attachments)
                        returns ListenerError? = @java:Method {
    name: "attach",
    'class: "org.ballerinalang.stdlib.task.actions.TaskActions"
} external;

isolated function validateConfiguration(TimerConfiguration|AppointmentConfiguration configuration) {
    var noOfRecurrences = configuration.noOfRecurrences;
    var initalDelay = configuration[INITIAL_DELAY];
    var misfirePolicy = configuration.misfirePolicy;
    if (configuration is TimerConfiguration) {
        if (noOfRecurrences < 0) {
            panic error ListenerError("Task noOfOccurrences should be a positive integer.");
        } else if (noOfRecurrences == 1) {
            if (!(misfirePolicy is OneTimeTaskPolicy)) {
                panic error ListenerError("Wrong misfire policy has been given for the one-time execution timer tasks.");
            }
        } else {
            if (!(misfirePolicy is RecurringTaskPolicy)) {
                panic error ListenerError("Wrong misfire policy has been given for the repeating execution timer tasks.");
            }
        }
        if (configuration.intervalInMillis < 1) {
            panic error ListenerError("Timer scheduling interval should be a positive integer.");
        }
        if (initalDelay == ()) {
            configuration.initialDelayInMillis = configuration.intervalInMillis;
        } else {
            if (initalDelay is int && initalDelay < 0) {
                panic error ListenerError("Timer scheduling delay should be a non-negative integer.");
            }
        }
    } else if (!(misfirePolicy is AppointmentMisfirePolicy)) {
        panic error ListenerError("Wrong misfire policy has given for the appointment task.");
    }
}
