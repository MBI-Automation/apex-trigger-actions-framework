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
public class TriggerActionFlowTest {
	private static final String MY_ACCOUNT = 'My Account';
	private static final String OLD_NAME = 'Old Name';
	private static final String BOGUS = 'Bogus';
	private static final String SAMPLE_FLOW_NAME = 'TriggerActionFlowTest';
	private static final String INPUT_GENERATOR_CLASS_NAME = 'TriggerActionFlowTest.AccountTriggerRecord';
	private static final String INPUT_GENERATOR_CLASS_NAME_WRONG_VARIABLE = 'TriggerActionFlowTest.BadInputWrongVariable';
	private static final String INPUT_GENERATOR_CLASS_NAME_WRONG_TYPE = 'TriggerActionFlowTest.BadInputWrongReturnType';
	private static Account myAccount = new Account(
		Name = MY_ACCOUNT,
		Id = TestUtility.getFakeId(Schema.Account.SObjectType)
	);
	private static Account oldAccount = new Account(
		Name = OLD_NAME,
		Id = myAccount.Id
	);
	private static List<SObject> newList = new List<SObject>{ myAccount };
	private static List<SObject> oldList = new List<SObject>{ oldAccount };
	private static TriggerActionFlow actionFlow;
	private static Exception myException;

	static {
		actionFlow = new TriggerActionFlow();
		actionFlow.flowName = SAMPLE_FLOW_NAME;
		actionFlow.flowTriggerRecordClassName = INPUT_GENERATOR_CLASS_NAME;
		actionFlow.allowRecursion = true;
	}

	@IsTest
	private static void beforeInsertShouldSucceed() {
		try {
			actionFlow.beforeInsert(newList);
		} catch (Exception e) {
			myException = e;
		}

		System.assertEquals(
			null,
			myException,
			'There should be no exception thrown when this method is called with a valid flow.'
		);
	}

	@IsTest
	private static void afterInsertShouldSucceed() {
		try {
			actionFlow.afterInsert(newList);
		} catch (Exception e) {
			myException = e;
		}

		System.assertEquals(
			null,
			myException,
			'There should be no exception thrown when this method is called with a valid flow.'
		);
	}

	@IsTest
	private static void beforeUpdateShouldSucceed() {
		try {
			actionFlow.beforeUpdate(newList, oldList);
		} catch (Exception e) {
			myException = e;
		}

		System.assertEquals(
			null,
			myException,
			'There should be no exception thrown when this method is called with a valid flow.'
		);
	}

	@IsTest
	private static void afterUpdateShouldSucceed() {
		try {
			actionFlow.afterUpdate(newList, oldList);
		} catch (Exception e) {
			myException = e;
		}

		System.assertEquals(
			null,
			myException,
			'There should be no exception thrown when this method is called with a valid flow.'
		);
	}

	@IsTest
	private static void beforeDeleteShouldSucceed() {
		try {
			actionFlow.beforeDelete(newList);
		} catch (Exception e) {
			myException = e;
		}

		System.assertEquals(
			null,
			myException,
			'There should be no exception thrown when this method is called with a valid flow.'
		);
	}

	@IsTest
	private static void afterDeleteShouldSucceed() {
		try {
			actionFlow.afterDelete(newList);
		} catch (Exception e) {
			myException = e;
		}

		System.assertEquals(
			null,
			myException,
			'There should be no exception thrown when this method is called with a valid flow.'
		);
	}

	@IsTest
	private static void afterUndeleteShouldSucceed() {
		try {
			actionFlow.afterUndelete(oldList);
		} catch (Exception e) {
			myException = e;
		}

		System.assertEquals(
			null,
			myException,
			'There should be no exception thrown when this method is called with a valid flow.'
		);
	}

	@IsTest
	private static void beforeInputShouldFailWithNullInputGenerator() {
		try {
			actionFlow.flowTriggerRecordClassName = null;
			actionFlow.beforeInsert(newList);
		} catch (TriggerActionFlow.TriggerActionFlowException e) {
			myException = e;
		}

		System.assertNotEquals(
			null,
			myException,
			'An exception should be thrown when there is no specified input generator class name.'
		);
	}

	@IsTest
	private static void beforeInputShouldFailWithInvalidInputGenerator() {
		try {
			actionFlow.flowTriggerRecordClassName = BOGUS;
			actionFlow.beforeInsert(newList);
		} catch (TriggerActionFlow.TriggerActionFlowException e) {
			myException = e;
		}

		System.assertNotEquals(
			null,
			myException,
			'An exception should be thrown when there is no valid input generator class name.'
		);
	}

	@IsTest
	private static void beforeInputShouldFailWithInvalidInputMissingKey() {
		try {
			actionFlow.flowTriggerRecordClassName = INPUT_GENERATOR_CLASS_NAME_WRONG_VARIABLE;
			actionFlow.beforeInsert(newList);
		} catch (TriggerActionFlow.TriggerActionFlowException e) {
			myException = e;
		}

		System.assertNotEquals(
			null,
			myException,
			'An exception should be thrown when the input generated does not contain the key "triggerRecords"'
		);
	}

	@IsTest
	private static void beforeInputShouldFailWithInvalidInputWrongDataType() {
		try {
			actionFlow.flowTriggerRecordClassName = INPUT_GENERATOR_CLASS_NAME_WRONG_TYPE;
			actionFlow.beforeInsert(newList);
		} catch (TriggerActionFlow.TriggerActionFlowException e) {
			myException = e;
		}

		System.assertNotEquals(
			null,
			myException,
			'An exception should be thrown when the input generated has the key "triggerRecords", but it is mapped to a value that is not a list of TriggerRecord'
		);
	}

	@IsTest
	private static void bypassShouldSucceed() {
		TriggerActionFlow.bypass(SAMPLE_FLOW_NAME);

		System.assert(
			TriggerActionFlow.bypassedFlows.contains(SAMPLE_FLOW_NAME),
			'Static bypasses should be populated properly'
		);
	}

	@IsTest
	private static void clearBypassShouldSucceed() {
		TriggerActionFlow.bypass(SAMPLE_FLOW_NAME);
		TriggerActionFlow.clearBypass(SAMPLE_FLOW_NAME);

		System.assert(
			!TriggerActionFlow.bypassedFlows.contains(SAMPLE_FLOW_NAME),
			'Static bypasses should be populated properly'
		);
	}

	@IsTest
	private static void isBypassedShouldSucceed() {
		Boolean isBypassed;
		TriggerActionFlow.bypass(SAMPLE_FLOW_NAME);

		isBypassed = TriggerActionFlow.isBypassed(SAMPLE_FLOW_NAME);

		System.assertEquals(
			true,
			isBypassed,
			'Static bypasses should be populated properly'
		);
	}

	@IsTest
	private static void clearAllBypassesShouldSucceed() {
		TriggerActionFlow.bypass(SAMPLE_FLOW_NAME);

		TriggerActionFlow.clearAllBypasses();

		System.assertEquals(
			0,
			TriggerActionFlow.bypassedFlows.size(),
			'Static bypasses should be populated properly'
		);
	}

	public class AccountTriggerRecord extends FlowTriggerRecord {
		public AccountTriggerRecord() {
			super();
		}

		public AccountTriggerRecord(
			Account newRecord,
			Account oldRecord,
			Integer newRecordIndex,
			Integer triggerActionFlowIdentifier
		) {
			super(newRecord, oldRecord, newRecordIndex, triggerActionFlowIdentifier);
		}

		@AuraEnabled
		public Account newRecord {
			get {
				return (Account) this.newSObject;
			}
			set {
				this.newSObject = value;
			}
		}

		@AuraEnabled
		public Account oldRecord {
			get {
				return (Account) this.oldSObject;
			}
		}

		public override Map<String, Object> getFlowInput(
			List<SObject> newList,
			List<SObject> oldList,
			Integer triggerActionFlowIdentifier
		) {
			List<SObject> collection = newList != null ? newList : oldList;
			List<AccountTriggerRecord> triggerRecords = new List<AccountTriggerRecord>();
			for (Integer i = 0; i < collection.size(); i++) {
				Account newRecord = newList != null ? (Account) newList.get(i) : null;
				Account oldRecord = oldList != null ? (Account) oldList.get(i) : null;
				triggerRecords.add(
					new AccountTriggerRecord(
						newRecord,
						oldRecord,
						i,
						triggerActionFlowIdentifier
					)
				);
			}
			return new Map<String, Object>{
				TriggerActionFlow.TRIGGER_RECORDS_VARIABLE => triggerRecords
			};
		}
	}

	private class BadInputWrongVariable extends FlowTriggerRecord {
		public override Map<String, Object> getFlowInput(
			List<SObject> newList,
			List<SObject> oldList,
			Integer triggerActionFlowIdentifier
		) {
			return new Map<String, Object>{
				BOGUS => new List<AccountTriggerRecord>()
			};
		}
	}

	private class BadInputWrongReturnType extends FlowTriggerRecord {
		public override Map<String, Object> getFlowInput(
			List<SObject> newList,
			List<SObject> oldList,
			Integer triggerActionFlowIdentifier
		) {
			return new Map<String, Object>{
				TriggerActionFlow.TRIGGER_RECORDS_VARIABLE => BOGUS
			};
		}
	}
}
