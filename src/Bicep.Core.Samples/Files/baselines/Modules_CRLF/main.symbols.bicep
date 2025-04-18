
@sys.description('this is deployTimeSuffix param')
param deployTimeSuffix string = newGuid()
//@[06:22) Parameter deployTimeSuffix. Type: string. Declaration start char: 0, length: 93

@sys.description('this module a')
module modATest './modulea.bicep' = {
//@[07:15) Module modATest. Type: module. Declaration start char: 0, length: 252
  name: 'modATest'
  params: {
    stringParamB: 'hello!'
    objParam: {
      a: 'b'
    }
    arrayParam: [
      {
        a: 'b'
      }
      'abc'
    ]
  }
}


@sys.description('this module b')
module modB './child/moduleb.bicep' = {
//@[07:11) Module modB. Type: module. Declaration start char: 0, length: 136
  name: 'modB'
  params: {
    location: 'West US'
  }
}

@sys.description('this is just module b with a condition')
module modBWithCondition './child/moduleb.bicep' = if (1 + 1 == 2) {
//@[07:24) Module modBWithCondition. Type: module. Declaration start char: 0, length: 203
  name: 'modBWithCondition'
  params: {
    location: 'East US'
  }
}

module modBWithCondition2 './child/moduleb.bicep' =
//@[07:25) Module modBWithCondition2. Type: module. Declaration start char: 0, length: 166
// awkward comment
if (1 + 1 == 2) {
  name: 'modBWithCondition2'
  params: {
    location: 'East US'
  }
}

module modC './child/modulec.json' = {
//@[07:11) Module modC. Type: module. Declaration start char: 0, length: 100
  name: 'modC'
  params: {
    location: 'West US'
  }
}

module modCWithCondition './child/modulec.json' = if (2 - 1 == 1) {
//@[07:24) Module modCWithCondition. Type: module. Declaration start char: 0, length: 142
  name: 'modCWithCondition'
  params: {
    location: 'East US'
  }
}

module optionalWithNoParams1 './child/optionalParams.bicep'= {
//@[07:28) Module optionalWithNoParams1. Type: module. Declaration start char: 0, length: 98
  name: 'optionalWithNoParams1'
}

module optionalWithNoParams2 './child/optionalParams.bicep'= {
//@[07:28) Module optionalWithNoParams2. Type: module. Declaration start char: 0, length: 116
  name: 'optionalWithNoParams2'
  params: {
  }
}

module optionalWithAllParams './child/optionalParams.bicep'= {
//@[07:28) Module optionalWithAllParams. Type: module. Declaration start char: 0, length: 210
  name: 'optionalWithNoParams3'
  params: {
    optionalString: 'abc'
    optionalInt: 42
    optionalObj: { }
    optionalArray: [ ]
  }
}

resource resWithDependencies 'Mock.Rp/mockResource@2020-01-01' = {
//@[09:28) Resource resWithDependencies. Type: Mock.Rp/mockResource@2020-01-01. Declaration start char: 0, length: 233
  name: 'harry'
  properties: {
    modADep: modATest.outputs.stringOutputA
    modBDep: modB.outputs.myResourceId
    modCDep: modC.outputs.myResourceId
  }
}

module optionalWithAllParamsAndManualDependency './child/optionalParams.bicep'= {
//@[07:47) Module optionalWithAllParamsAndManualDependency. Type: module. Declaration start char: 0, length: 321
  name: 'optionalWithAllParamsAndManualDependency'
  params: {
    optionalString: 'abc'
    optionalInt: 42
    optionalObj: { }
    optionalArray: [ ]
  }
  dependsOn: [
    resWithDependencies
    optionalWithAllParams
  ]
}

module optionalWithImplicitDependency './child/optionalParams.bicep'= {
//@[07:37) Module optionalWithImplicitDependency. Type: module. Declaration start char: 0, length: 300
  name: 'optionalWithImplicitDependency'
  params: {
    optionalString: concat(resWithDependencies.id, optionalWithAllParamsAndManualDependency.name)
    optionalInt: 42
    optionalObj: { }
    optionalArray: [ ]
  }
}

module moduleWithCalculatedName './child/optionalParams.bicep'= {
//@[07:31) Module moduleWithCalculatedName. Type: module. Declaration start char: 0, length: 331
  name: '${optionalWithAllParamsAndManualDependency.name}${deployTimeSuffix}'
  params: {
    optionalString: concat(resWithDependencies.id, optionalWithAllParamsAndManualDependency.name)
    optionalInt: 42
    optionalObj: { }
    optionalArray: [ ]
  }
}

resource resWithCalculatedNameDependencies 'Mock.Rp/mockResource@2020-01-01' = {
//@[09:42) Resource resWithCalculatedNameDependencies. Type: Mock.Rp/mockResource@2020-01-01. Declaration start char: 0, length: 241
  name: '${optionalWithAllParamsAndManualDependency.name}${deployTimeSuffix}'
  properties: {
    modADep: moduleWithCalculatedName.outputs.outputObj
  }
}

output stringOutputA string = modATest.outputs.stringOutputA
//@[07:20) Output stringOutputA. Type: string. Declaration start char: 0, length: 60
output stringOutputB string = modATest.outputs.stringOutputB
//@[07:20) Output stringOutputB. Type: string. Declaration start char: 0, length: 60
output objOutput object = modATest.outputs.objOutput
//@[07:16) Output objOutput. Type: object. Declaration start char: 0, length: 52
output arrayOutput array = modATest.outputs.arrayOutput
//@[07:18) Output arrayOutput. Type: array. Declaration start char: 0, length: 55
output modCalculatedNameOutput object = moduleWithCalculatedName.outputs.outputObj
//@[07:30) Output modCalculatedNameOutput. Type: object. Declaration start char: 0, length: 82

/*
  valid loop cases
*/

@sys.description('this is myModules')
var myModules = [
//@[04:13) Variable myModules. Type: [object, object]. Declaration start char: 0, length: 162
  {
    name: 'one'
    location: 'eastus2'
  }
  {
    name: 'two'
    location: 'westus'
  }
]

var emptyArray = []
//@[04:14) Variable emptyArray. Type: <empty array>. Declaration start char: 0, length: 19

// simple module loop
module storageResources 'modulea.bicep' = [for module in myModules: {
//@[47:53) Local module. Type: object | object. Declaration start char: 47, length: 6
//@[07:23) Module storageResources. Type: module[]. Declaration start char: 0, length: 189
  name: module.name
  params: {
    arrayParam: []
    objParam: module
    stringParamB: module.location
  }
}]

// simple indexed module loop
module storageResourcesWithIndex 'modulea.bicep' = [for (module, i) in myModules: {
//@[57:63) Local module. Type: object | object. Declaration start char: 57, length: 6
//@[65:66) Local i. Type: int. Declaration start char: 65, length: 1
//@[07:32) Module storageResourcesWithIndex. Type: module[]. Declaration start char: 0, length: 256
  name: module.name
  params: {
    arrayParam: [
      i + 1
    ]
    objParam: module
    stringParamB: module.location
    stringParamA: concat('a', i)
  }
}]

// nested module loop
module nestedModuleLoop 'modulea.bicep' = [for module in myModules: {
//@[47:53) Local module. Type: object | object. Declaration start char: 47, length: 6
//@[07:23) Module nestedModuleLoop. Type: module[]. Declaration start char: 0, length: 246
  name: module.name
  params: {
    arrayParam: [for i in range(0,3): concat('test-', i, '-', module.name)]
//@[21:22) Local i. Type: int. Declaration start char: 21, length: 1
    objParam: module
    stringParamB: module.location
  }
}]

// duplicate identifiers across scopes are allowed (inner hides the outer)
module duplicateIdentifiersWithinLoop 'modulea.bicep' = [for x in emptyArray:{
//@[61:62) Local x. Type: never. Declaration start char: 61, length: 1
//@[07:37) Module duplicateIdentifiersWithinLoop. Type: module[]. Declaration start char: 0, length: 234
  name: 'hello-${x}'
  params: {
    objParam: {}
    stringParamA: 'test'
    stringParamB: 'test'
    arrayParam: [for x in emptyArray: x]
//@[21:22) Local x. Type: never. Declaration start char: 21, length: 1
  }
}]

// duplicate identifiers across scopes are allowed (inner hides the outer)
var duplicateAcrossScopes = 'hello'
//@[04:25) Variable duplicateAcrossScopes. Type: 'hello'. Declaration start char: 0, length: 35
module duplicateInGlobalAndOneLoop 'modulea.bicep' = [for duplicateAcrossScopes in []: {
//@[58:79) Local duplicateAcrossScopes. Type: never. Declaration start char: 58, length: 21
//@[07:34) Module duplicateInGlobalAndOneLoop. Type: module[]. Declaration start char: 0, length: 264
  name: 'hello-${duplicateAcrossScopes}'
  params: {
    objParam: {}
    stringParamA: 'test'
    stringParamB: 'test'
    arrayParam: [for x in emptyArray: x]
//@[21:22) Local x. Type: never. Declaration start char: 21, length: 1
  }
}]

var someDuplicate = true
//@[04:17) Variable someDuplicate. Type: true. Declaration start char: 0, length: 24
var otherDuplicate = false
//@[04:18) Variable otherDuplicate. Type: false. Declaration start char: 0, length: 26
module duplicatesEverywhere 'modulea.bicep' = [for someDuplicate in []: {
//@[51:64) Local someDuplicate. Type: never. Declaration start char: 51, length: 13
//@[07:27) Module duplicatesEverywhere. Type: module[]. Declaration start char: 0, length: 263
  name: 'hello-${someDuplicate}'
  params: {
    objParam: {}
    stringParamB: 'test'
    arrayParam: [for otherDuplicate in emptyArray: '${someDuplicate}-${otherDuplicate}']
//@[21:35) Local otherDuplicate. Type: never. Declaration start char: 21, length: 14
  }
}]

module propertyLoopInsideParameterValue 'modulea.bicep' = {
//@[07:39) Module propertyLoopInsideParameterValue. Type: module. Declaration start char: 0, length: 438
  name: 'propertyLoopInsideParameterValue'
  params: {
    objParam: {
      a: [for i in range(0,10): i]
//@[14:15) Local i. Type: int. Declaration start char: 14, length: 1
      b: [for i in range(1,2): i]
//@[14:15) Local i. Type: int. Declaration start char: 14, length: 1
      c: {
        d: [for j in range(2,3): j]
//@[16:17) Local j. Type: int. Declaration start char: 16, length: 1
      }
      e: [for k in range(4,4): {
//@[14:15) Local k. Type: int. Declaration start char: 14, length: 1
        f: k
      }]
    }
    stringParamB: ''
    arrayParam: [
      {
        e: [for j in range(7,7): j]
//@[16:17) Local j. Type: int. Declaration start char: 16, length: 1
      }
    ]
  }
}

module propertyLoopInsideParameterValueWithIndexes 'modulea.bicep' = {
//@[07:50) Module propertyLoopInsideParameterValueWithIndexes. Type: module. Declaration start char: 0, length: 514
  name: 'propertyLoopInsideParameterValueWithIndexes'
  params: {
    objParam: {
      a: [for (i, i2) in range(0,10): i + i2]
//@[15:16) Local i. Type: int. Declaration start char: 15, length: 1
//@[18:20) Local i2. Type: int. Declaration start char: 18, length: 2
      b: [for (i, i2) in range(1,2): i / i2]
//@[15:16) Local i. Type: int. Declaration start char: 15, length: 1
//@[18:20) Local i2. Type: int. Declaration start char: 18, length: 2
      c: {
        d: [for (j, j2) in range(2,3): j * j2]
//@[17:18) Local j. Type: int. Declaration start char: 17, length: 1
//@[20:22) Local j2. Type: int. Declaration start char: 20, length: 2
      }
      e: [for (k, k2) in range(4,4): {
//@[15:16) Local k. Type: int. Declaration start char: 15, length: 1
//@[18:20) Local k2. Type: int. Declaration start char: 18, length: 2
        f: k
        g: k2
      }]
    }
    stringParamB: ''
    arrayParam: [
      {
        e: [for j in range(7,7): j]
//@[16:17) Local j. Type: int. Declaration start char: 16, length: 1
      }
    ]
  }
}

module propertyLoopInsideParameterValueInsideModuleLoop 'modulea.bicep' = [for thing in range(0,1): {
//@[79:84) Local thing. Type: 0. Declaration start char: 79, length: 5
//@[07:55) Module propertyLoopInsideParameterValueInsideModuleLoop. Type: module[]. Declaration start char: 0, length: 535
  name: 'propertyLoopInsideParameterValueInsideModuleLoop'
  params: {
    objParam: {
      a: [for i in range(0,10): i + thing]
//@[14:15) Local i. Type: int. Declaration start char: 14, length: 1
      b: [for i in range(1,2): i * thing]
//@[14:15) Local i. Type: int. Declaration start char: 14, length: 1
      c: {
        d: [for j in range(2,3): j]
//@[16:17) Local j. Type: int. Declaration start char: 16, length: 1
      }
      e: [for k in range(4,4): {
//@[14:15) Local k. Type: int. Declaration start char: 14, length: 1
        f: k - thing
      }]
    }
    stringParamB: ''
    arrayParam: [
      {
        e: [for j in range(7,7): j % (thing + 1)]
//@[16:17) Local j. Type: int. Declaration start char: 16, length: 1
      }
    ]
  }
}]


// BEGIN: Key Vault Secret Reference

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
//@[09:11) Resource kv. Type: Microsoft.KeyVault/vaults@2019-09-01. Declaration start char: 0, length: 90
  name: 'testkeyvault'
}

module secureModule1 'child/secureParams.bicep' = {
//@[07:20) Module secureModule1. Type: module. Declaration start char: 0, length: 213
  name: 'secureModule1'
  params: {
    secureStringParam1: kv.getSecret('mySecret')
    secureStringParam2: kv.getSecret('mySecret','secretVersion')
  }
}

resource scopedKv 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
//@[09:17) Resource scopedKv. Type: Microsoft.KeyVault/vaults@2019-09-01. Declaration start char: 0, length: 134
  name: 'testkeyvault'
  scope: resourceGroup('otherGroup')
}

module secureModule2 'child/secureParams.bicep' = {
//@[07:20) Module secureModule2. Type: module. Declaration start char: 0, length: 225
  name: 'secureModule2'
  params: {
    secureStringParam1: scopedKv.getSecret('mySecret')
    secureStringParam2: scopedKv.getSecret('mySecret','secretVersion')
  }
}

//looped module with looped existing resource (Issue #2862)
var vaults = [
//@[04:10) Variable vaults. Type: [object, object]. Declaration start char: 0, length: 200
  {
    vaultName: 'test-1-kv'
    vaultRG: 'test-1-rg'
    vaultSub: 'abcd-efgh'
  }
  {
    vaultName: 'test-2-kv'
    vaultRG: 'test-2-rg'
    vaultSub: 'ijkl-1adg1'
  }
]
var secrets = [
//@[04:11) Variable secrets. Type: [object, object]. Declaration start char: 0, length: 132
  {
    name: 'secret01'
    version: 'versionA'
  }
  {
    name: 'secret02'
    version: 'versionB'
  }
]

resource loopedKv 'Microsoft.KeyVault/vaults@2019-09-01' existing = [for vault in vaults: {
//@[73:78) Local vault. Type: object | object. Declaration start char: 73, length: 5
//@[09:17) Resource loopedKv. Type: Microsoft.KeyVault/vaults@2019-09-01[]. Declaration start char: 0, length: 175
  name: vault.vaultName
  scope: resourceGroup(vault.vaultSub, vault.vaultRG)
}]

module secureModuleLooped 'child/secureParams.bicep' = [for (secret, i) in secrets: {
//@[61:67) Local secret. Type: object | object. Declaration start char: 61, length: 6
//@[69:70) Local i. Type: int. Declaration start char: 69, length: 1
//@[07:25) Module secureModuleLooped. Type: module[]. Declaration start char: 0, length: 278
  name: 'secureModuleLooped-${i}'
  params: {
    secureStringParam1: loopedKv[i].getSecret(secret.name)
    secureStringParam2: loopedKv[i].getSecret(secret.name, secret.version)
  }
}]

module secureModuleCondition 'child/secureParams.bicep' = {
//@[07:28) Module secureModuleCondition. Type: module. Declaration start char: 0, length: 285
  name: 'secureModuleCondition'
  params: {
    secureStringParam1: true ? kv.getSecret('mySecret') : 'notTrue'
    secureStringParam2: true ? false ? 'false' : kv.getSecret('mySecret','secretVersion') : 'notTrue'
  }
}

// END: Key Vault Secret Reference

module withSpace 'module with space.bicep' = {
//@[07:16) Module withSpace. Type: module. Declaration start char: 0, length: 70
  name: 'withSpace'
}

module folderWithSpace 'child/folder with space/child with space.bicep' = {
//@[07:22) Module folderWithSpace. Type: module. Declaration start char: 0, length: 104
  name: 'childWithSpace'
}

// nameof

var nameofModule = nameof(folderWithSpace)
//@[04:16) Variable nameofModule. Type: 'folderWithSpace'. Declaration start char: 0, length: 42
var nameofModuleParam = nameof(secureModuleCondition.outputs.exposedSecureString)
//@[04:21) Variable nameofModuleParam. Type: 'exposedSecureString'. Declaration start char: 0, length: 81

module moduleWithNameof 'modulea.bicep' = {
//@[07:23) Module moduleWithNameof. Type: module. Declaration start char: 0, length: 358
  name: 'nameofModule'
  scope: resourceGroup(nameof(nameofModuleParam))
  params:{
    stringParamA: nameof(withSpace)
    stringParamB: nameof(folderWithSpace)
    objParam: {
      a: nameof(secureModuleCondition.outputs.exposedSecureString)
    }
    arrayParam: [
      nameof(vaults)
    ]
  }
}

module moduleWithNullableOutputs 'child/nullableOutputs.bicep' = {
//@[07:32) Module moduleWithNullableOutputs. Type: module. Declaration start char: 0, length: 96
  name: 'nullableOutputs'
}

output nullableString string? = moduleWithNullableOutputs.outputs.?nullableString
//@[07:21) Output nullableString. Type: null | string. Declaration start char: 0, length: 81
output deeplyNestedProperty string? = moduleWithNullableOutputs.outputs.?nullableObj.deeply.nested.property
//@[07:27) Output deeplyNestedProperty. Type: null | string. Declaration start char: 0, length: 107
output deeplyNestedArrayItem string? = moduleWithNullableOutputs.outputs.?nullableObj.deeply.nested.array[0]
//@[07:28) Output deeplyNestedArrayItem. Type: null | string. Declaration start char: 0, length: 108
output deeplyNestedArrayItemFromEnd string? = moduleWithNullableOutputs.outputs.?nullableObj.deeply.nested.array[^1]
//@[07:35) Output deeplyNestedArrayItemFromEnd. Type: null | string. Declaration start char: 0, length: 116
output deeplyNestedArrayItemFromEndAttempt string? = moduleWithNullableOutputs.outputs.?nullableObj.deeply.nested.array[?^1]
//@[07:42) Output deeplyNestedArrayItemFromEndAttempt. Type: null | string. Declaration start char: 0, length: 124

