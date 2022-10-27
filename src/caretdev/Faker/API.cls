Class caretdev.Faker.API Extends %CSP.REST
{

Parameter CONTENTTYPE = {..#CONTENTTYPEJSON};

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
  <Route Url="/" Method="GET" Call="CheckStatus" Cors="true"/>
  <Route Url="/datatype" Method="GET" Call="GetDatatypeList" Cors="true"/>
  <Route Url="/locale" Method="GET" Call="GetLocalesList" Cors="true"/>
  <Route Url="/preview" Method="POST" Call="Preview" Cors="true"/>
  <Route Url="/test" Method="GET" Call="Test" Cors="true"/>
  <Route Url="/generate" Method="POST" Call="Generate" Cors="true"/>

</Routes>
}

ClassMethod outputStatus(pSC As %Status) As %Status
{
  #; All good, very good
  Set result = {
    "status": "OK"
  }
  If ($$$ISERR(pSC)) {
    Do $System.Status.DecomposeStatus(pSC, .errors)
    #; zw errors
    If $Data(errors(1)) {
      Set code = errors(1, "code")
      Set error = $Piece(errors(1), "#" _ code _": ", 2, *)
      #; Set error = $Get(errors(1, "param", 1), error)
      Set result.code = code
      Set result.status = error
    }
  }
  Do result.%ToJSON()
  Return $$$OK
}

ClassMethod ReportHttpStatusCode(pHttpStatus, pSC As %Status = {$$$OK}) As %Status
{
  Set %response.Status=pHttpStatus

  If $$$ISERR(pSC) {
    Do ..outputStatus(pSC)
  }
  Else {
    Set result = {
      "status": (pHttpStatus)
    }
    Do result.%ToJSON()
  }

  Quit $$$OK
}

ClassMethod CheckStatus() As %Status
{
  If '$system.CLS.IsMthd("%SYS.Python","Import") {
    Quit $$$ERROR($$$GeneralError, "Incompatible version of IRIS. Requires the version with Python Embedded support.")
  }
  try {
    Set faker = ##class(%SYS.Python).Import("faker")
  } catch e {
    If e.Data["'ModuleNotFoundError'" {
      Return $$$ERROR($$$GeneralError, "Python module 'faker' not installed. Please install it with pip3.")
    }
    Return e.AsStatus()
  }

  Set result = {
    "status": "OK"
  }
  Do result.%ToJSON()
  Return $$$OK
}

ClassMethod GetDatatypeList() As %DynamicObject
{
  Set result = []

  Set clsDef = ##class(%Dictionary.ClassDefinition).%OpenId("caretdev.Faker.Main")
  Set key = ""
  For {
    Set method = clsDef.Methods.GetNext(.key)
    Quit:key=""
    Continue:$Piece(method.Name,"_")'="type"
    Set order = method.SequenceNumber
    Set type = $Piece(method.Name, "_", 2, *)
    Set metaInfo = $ListFromString($Translate(method.Description, $Char(13)), $Char(10))
    Set group = $ListGet(metaInfo, 1)
    Set name = $ListGet(metaInfo, 2)
    Set options = ""
    For i=3:1:$ListLength(metaInfo) {
      Set line = $ZStrip($ListGet(metaInfo, i), "*WC")
      Set option = $Piece(line, "@", 2)
      If option'="" {
        Set options = options _ $ListBuild(option)
      }
    }

    Set groupOrder = $Get(groupOrder(group), order)
    Set groupOrder(group) = groupOrder

    Set list(groupOrder) = group
    Set list(groupOrder, order) = $ListBuild(name, type, options)
  }

  Set groupInd = ""
  For {
    Set groupInd = $Order(list(groupInd), 1, group)
    Quit:groupInd=""

    Set items = []
    Set ind = ""
    For {
      Set ind = $Order(list(groupInd, ind), 1, info)
      Quit:ind=""
      Set $ListBuild(name, type, options) = info

      Set item = {
        "name": (name),
        "type": (type)
      }
      If options'="" {
        Set item.options = {}
        Set ptr = 0
        While $ListNext(options, ptr, option) {
          Set $ListBuild(name, type, default) = $ListFromString(option, ":")
          Set option = {
            "type": (type)
          }
          If $Get(default)'="" {
            If type="number" Set default = +default
            Set option.default = default
          }
          Set $Property(item.options, name) = option
        }
      }
      Do items.%Push(item)
    }
    Do result.%Push({
      "group": (group),
      "items": (items)
    })
  }

  Do result.%ToJSON()
  Quit $$$OK
}

ClassMethod GetLocalesList() As %Status [ Language = python ]
{
  import json
  from faker import config
  print(json.dumps(config.AVAILABLE_LOCALES))
  return 1
}

ClassMethod Preview() As %Status
{
  Set faker = ##class(Main).%New()
  $$$QuitOnError(faker.%JSONImport(%request.Content))
  Set result = faker.Generate()
  Set json = ##class(%SYS.Python).Import("json")
  Write json.dumps(result)
  Return $$$OK
}

ClassMethod Test() As %Status
{
  Set result = ##class(Main).Test()
  Set json = ##class(%SYS.Python).Import("json")
  Write json.dumps(result)

  Return $$$OK
}

ClassMethod Generate() As %Status
{
  If (%request.GetCgiEnv("SERVER_NAME")["demo.community.intersystems.com") {
    Return $$$ERROR($$$GeneralError, "Disabled on Demo server")
  }
  Set faker = ##class(Main).%New()
  Set params = {}.%FromJSON(%request.Content)
  Set rows = +params.%Get("rows")
  If rows'>0 {
    Quit $$$ERROR($$$GeneralError, "Rows must be more then 0")
  }
  Set className = params.%Get("className")
  $$$QuitOnError(faker.%JSONImport(params))
  If params.%Get("createClass", 1) {
    $$$QuitOnError(faker.GenerateClass(.tableName))
  }
  Set result = faker.Generate()
  If $$$ISERR(result) Quit result
  Set json = ##class(%SYS.Python).Import("json")
  Write json.dumps(result)
  Return $$$OK
}

}
