/*
   Copyright 2021 Google LLC

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

	https://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */

@IsTest(isParallel=true)
private class TriggerActionFlowBypassTest {
	private static final String MY_STRING = 'MY_STRING';
	private static List<TriggerActionFlowBypass.Request> requests = new List<TriggerActionFlowBypass.Request>();
	private static TriggerActionFlowBypass.Request request = new TriggerActionFlowBypass.Request();
	private static Exception myException;

	@IsTest
	private static void bypassObjectShouldSucceedWithValidRequest() {
		request.Name = MY_STRING;
		request.bypassType = TriggerActionFlow.OBJECT_STRING;
		requests.add(request);

		TriggerActionFlowBypass.bypass(requests);

		System.assertEquals(
			true,
			TriggerBase.isBypassed(MY_STRING),
			'The Object should be bypassed'
		);
	}

	@IsTest
	private static void bypassApexShouldSucceedWithValidRequest() {
		request.Name = MY_STRING;
		request.bypassType = TriggerActionFlow.APEX_STRING;
		requests.add(request);

		TriggerActionFlowBypass.bypass(requests);

		System.assertEquals(
			true,
			MetadataTriggerHandler.isBypassed(MY_STRING),
			'The Apex should be bypassed'
		);
	}

	@IsTest
	private static void bypassFlowShouldSucceedWithValidRequest() {
		request.Name = MY_STRING;
		request.bypassType = TriggerActionFlow.FLOW_STRING;
		requests.add(request);

		TriggerActionFlowBypass.bypass(requests);

		System.assertEquals(
			true,
			TriggerActionFlow.isBypassed(MY_STRING),
			'The Flow should be bypassed'
		);
	}

	@IsTest
	private static void bypassShouldFailWithInvalidRequest() {
		try {
			TriggerActionFlowBypass.bypass(
				new List<TriggerActionFlowBypass.Request>()
			);
		} catch (Exception e) {
			myException = e;
		}

		System.assertNotEquals(
			null,
			myException,
			'We should have an exception thrown in this scenario'
		);
		System.assert(
			myException instanceof TriggerActionFlowBypass.TriggerActionFlowBypassObjectException,
			'The exception should be of the correct type'
		);
		System.assertEquals(
			myException.getMessage(),
			TriggerActionFlowBypass.INVALID_REQUEST,
			'The exeption should contain the message we are looking for'
		);
	}

	@IsTest
	private static void bypassShouldFailWithInvalidType() {
		request.Name = MY_STRING;
		request.bypassType = MY_STRING;
		requests.add(request);

		try {
			TriggerActionFlowBypass.bypass(requests);
		} catch (Exception e) {
			myException = e;
		}

		System.assertNotEquals(
			null,
			myException,
			'We should have an exception thrown in this scenario'
		);
		System.assert(
			myException instanceof TriggerActionFlowBypass.TriggerActionFlowBypassObjectException,
			'The exception should be of the correct type'
		);
		System.assertEquals(
			myException.getMessage(),
			TriggerActionFlow.INVALID_TYPE,
			'The exeption should contain the message we are looking for'
		);
	}
}
