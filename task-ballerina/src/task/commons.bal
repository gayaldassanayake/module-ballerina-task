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

# Configurations related to a timer, which are used to define the behavior of a timer when initializing the
# `task:Listener`.
#
# + intervalInMillis - Timer interval (in milliseconds), which triggers the `onTrigger` resource
# + initialDelayInMillis - Delay (in milliseconds) after which the timer will run
# + noOfRecurrences - Number of times to trigger the task after which the task stops running
public type TimerConfiguration record {|
    int intervalInMillis;
    int initialDelayInMillis?;
    int noOfRecurrences?;
|};

# Configurations related to an appointment, which are used to define the behavior of an appointment when initializing
# the `task:Listener`.
#
# + appointmentDetails - A CRON expression as a string or `task:AppointmentData` for scheduling an appointment
# + noOfRecurrences - Number of times to trigger the task after which the task stops running
public type AppointmentConfiguration record {|
    string|AppointmentData appointmentDetails;
    int noOfRecurrences?;
|};

# The CRON expression required for scheduling an appointment.
#
# + seconds - Second(s) in a given minute in which the appointment will run
# + minutes - Minute(s) in a given hour in which the appointment will run
# + hours - Hour(s) in a given day in which the appointment will run
# + daysOfMonth - Day(s) of the month in which the appointment will run
# + months - Month(s) in a given year in which the appointment will run
# + daysOfWeek - Day(s) of a week in which the appointment will run
# + year - Year(s) in which the appointment will run
public type AppointmentData record {|
    string seconds?;
    string minutes?;
    string hours?;
    string daysOfMonth?;
    string months?;
    string daysOfWeek?;
    string year?;
|};

# Represents configurations for the misfire situations of the scheduler.
#
# + thresholdInMillis - The number of milliseconds the scheduler will tolerate a trigger to pass its
#                       next-fire-time by being considered `misfired` before.
# + policy - The policy, which is used to inform what it should do when a misfire occurs. The following are the
#            scenarios in which the policy can be used:
#               For a timer task:
#                   One-time task (the task will be run once):
#                       smartPolicy - This is the default policy, which will act as `firenow`
#                       fireNow - fireNow - Instructs the scheduler if the Trigger misfires. Then, the trigger wants
#                                 to be fired now by the scheduler.
#                       ignorePolicy - If the Trigger misfires, this instructs the scheduler that the trigger will
#                                      never be evaluated for a misfire situation and that the scheduler will
#                                      simply try to fire it as soon as it can and then update the trigger as
#                                      if it had fired at the proper time.
#                   Recurrinng task(the task will be run repeatedly):
#                       smartPolicy - This is the default policy. If the repeat count is indefinite, this will act
#                                     as the `rescheduleNextWithRemainigCount`. Else, it will act as the
#                                     `rescheduleNowWithExistingRepeatCount`.
#                       fireNextWithExistingCount - Instructs the scheduler if the trigger misfires. Then,
#                                                   the trigger wants to be re-scheduled to the next
#                                                   scheduled time after 'now' and with the repeat count
#                                                   left unchanged.
#                       fireNextWithRemainingCount - Instructs the scheduler if the trigger misfires. Then,
#                                                    the trigger wants to be re-scheduled to the next scheduled time
#                                                    after 'now' and with the repeat count set to what it would be
#                                                    if it had not missed any firings.
#                       fireNowWithExistingCount - Instructs the scheduler if the trigger misfires. Then,
#                                                  the trigger wants to be re-scheduled to 'now' with the
#                                                  repeat count left as it is. If 'now' is after the end-time
#                                                  the Trigger will not fire again as this does obey
#                                                  the Trigger end-time.
#                       fireNowWithRemainingCount - Instructs the scheduler if the trigger misfires. Then,
#                                                         the SimpleTrigger wants to be re-scheduled to
#                                                         'now' with the repeat count set to what it
#                                                          would be if it had not missed any firings.
#                       ignorePolicy - If the trigger misfires, this instructs the scheduler that the trigger will
#                                      never be evaluated for a misfire situation and that the scheduler will
#                                      simply try to fire it as soon as it can and then update the Trigger
#                                      as if it had fired at the proper time.
#           For the appointment task:
#               smartPolicy - This is the default policy, which will act as the `FireAndProceed`
#               ignorePolicy - If the Trigger misfires, this instructs the scheduler that the trigger will
#                              never be evaluated for a misfire situation and that the scheduler will
#                              simply try to fire it as soon as it can and then update the trigger as
#                              if it had fired at the proper time.
#               doNothing - Instructs the scheduler if the trigger misfires. Then, the trigger wants to have
#                           it's next-fire-time updated to the next time in the schedule after the current time.
#               fireAndProceed - Instructs the scheduler If the trigger misfires, the trigger wants to be fired
#                                now by the scheduler.
public type MisfireConfiguration record {|
    int thresholdInMillis = 5000;
    Policy policy = "smartPolicy";
|};

# Possible types of parameters that can be passed into the `Policy`.
public type Policy TimerTaskPolicy|AppointmentTaskPolicy;

# Possible types of parameters that can be passed into the `TimerTaskPolicy`.
public type TimerTaskPolicy RecurringTaskPolicy|OneTimeTaskPolicy;

# Possible types of parameters that can be passed into the `AppointmentTaskPolicy`.
public type AppointmentTaskPolicy SMART_POLICY|DO_NOTHING|FIRE_AND_PROCEED|IGNORE_POLICY;

# Possible types of parameters that can be passed into the `RecurringTaskPolicy`.
public type RecurringTaskPolicy SMART_POLICY|IGNORE_POLICY|FIRE_NEXT_WITH_EXISTING_COUNT|
FIRE_NEXT_WITH_REMAINING_COUNT|FIRE_NOW_WITH_EXISTING_COUNT|FIRE_NOW_WITH_REMAINING_COUNT;

# Possible types of parameters that can be passed into the `OneTimeTaskPolicy`.
public type OneTimeTaskPolicy SMART_POLICY|IGNORE_POLICY|FIRE_NOW;

public const string SMART_POLICY = "smartPolicy";
public const string DO_NOTHING = "doNothing";
public const string FIRE_AND_PROCEED = "fireAndProceed";
public const string FIRE_NEXT_WITH_EXISTING_COUNT = "fireNextWithExistingCount";
public const string FIRE_NEXT_WITH_REMAINING_COUNT = "fireNextWithRemainingCount";
public const string FIRE_NOW_WITH_EXISTING_COUNT = "fireNowWithExistingCount";
public const string FIRE_NOW_WITH_REMAINING_COUNT = "fireNowWithRemainingCount";
public const string FIRE_NOW = "fireNow";
public const string IGNORE_POLICY = "ignorePolicy";
