Class caretdev.Faker.Main Extends (%RegisteredObject, %JSON.Adaptor)
{

Parameter %JSONIGNOREINVALIDFIELD As BOOLEAN = 1;

Property locale As %String;

Property previewRows As %Integer [ InitialExpression = 5 ];

Property seed As %Integer(%JSONINCLUDE = "none") [ InitialExpression = -1 ];

Property columns As list Of ColumnInfo;

Property dateformat As %String [ InitialExpression = "%Y-%m-%d" ];

Property rows As %Integer [ InitialExpression = 100 ];

Property className As %String(MAXLEN = "");

ClassMethod Test()
{
  Set faker = ..%New()

  Set clsDef = ##class(%Dictionary.ClassDefinition).%OpenId($This)
  Set key = ""
  For {
    Set method = clsDef.Methods.GetNext(.key)
    Quit:key=""
    Continue:$Piece(method.Name,"_")'="type"

    Set column = ##class(ColumnInfo).%New()
    Set metaInfo = $ListFromString($Translate(method.Description, $Char(13)), $Char(10))
    Set group = $ListGet(metaInfo, 1)
    Set type = $ListGet(metaInfo, 2)
    Set column.name = group _ "_" _ type
    Set column.type = $Piece(method.Name,"_",2,*)
    Set list(method.SequenceNumber) = column
  }
  Set ind = ""
  For {
    Set ind = $Order(list(ind), 1, column)
    Quit:ind=""
    Do faker.columns.Insert(column)
  }


  Try {
    Set result = faker.Generate()
    Return result
  } Catch ex {
    ZWrite result
    ZWrite ex
  }
}

Method GenerateClass(Output tableName) As %Status
{
  If ..className="" {
    Quit $$$ERROR($$$GeneralError, "Empty ClassName")
  }
  If '$System.OBJ.IsValidClassname(..className) {
    Quit $$$ERROR($$$GeneralError, "ClassName is not valid")
  }
  If ##class(%Dictionary.ClassDefinition).%ExistsId(..className) {
    Quit $$$ERROR($$$GeneralError, "Class already exists")
  }

  Set tSC = $$$OK
  Try {
    Set clsDef = ##class(%Dictionary.ClassDefinition).%New(..className)
    Set clsDef.Super = "%Library.Persistent"

    Set key = ""
    For {
      Set column = ..columns.GetNext(.key)
      Quit:key=""
      Set property = ..CreateProperty(column.name, column.type)
      Do clsDef.Properties.Insert(property)
    }

    $$$ThrowOnError(clsDef.%Save())
    $$$ThrowOnError($System.OBJ.Compile(..className, "ck /nodisplay"))

    Set compiledClass = ##class(%Dictionary.CompiledClass).%OpenId(..className)
    Set tableName = compiledClass.SqlQualifiedNameQ
  } Catch e {
    Set tSC = e.AsStatus()
  }

  Quit tSC
}

ClassMethod CreateProperty(name As %String, type As %String) As %Dictionary.PropertyDefinition [ CodeMode = objectgenerator ]
{
  #define indent(%l) $Justify("",%l*2)
  Do %code.WriteLine($$$indent(1) _ "Set property = ##class(%Dictionary.PropertyDefinition).%New()" )
  Do %code.WriteLine($$$indent(1) _ "Set property.Name = name" )
  Set if = "If"
  Set key = ""
  For {
    Set method = %class.Methods.GetNext(.key)
    Quit:key=""
    Set dataType = $Piece(method.Name, "type_", 2, *)
    Continue:dataType=""
    Do %code.WriteLine($$$indent(1) _ if _ " type=" _ """" _ dataType _ """ {")
    Set type = $Select(method.ReturnType = "": "%String", 1: method.ReturnType)
    Do %code.WriteLine($$$indent(2) _ "Set property.Type = """ _ type _ """")
    Set params = $ListFromString(method.ReturnTypeParams)
    Set ptr = 0
    While $ListNext(params, ptr, param) {
      Set $ListBuild(paramName, paramValue) = $ListFromString(param, "=")
      Do %code.WriteLine($$$indent(2) _ "Do property.Parameters.SetAt(" _ paramValue _ ", """ _ paramName_ """)")

    }
    Do %code.WriteLine($$$indent(1) _ "}")
    Set if = "ElseIf"
  }
  Do %code.WriteLine($$$indent(1) _ "Quit property")
  Quit $$$OK
}

Method Generate() [ Language = python ]
{
  import iris
  import random
  from faker import Faker
  fake = Faker(self.locale)
  fake.seed_instance(self.seed if self.seed > -1 else None)

  preview = not self.className
  output = {
    "locale": self.locale,
    "columns": [],
    "items": []
  } if preview else {
    "status": [],
    "created": 0
  }
  num = self.previewRows if preview else self.rows

  needGender = False
  columns = []
  key = ""
  while key := self.columns.Next(key):
    columnInfo = self.columns.GetAt(key)
    name = columnInfo.name
    type = columnInfo.type
    columns.append([ name, type ])
    if preview:
      output["columns"].append({"name": name, "type": type})

    needGender = True if type == "gender" else needGender
    needGender = True if type == "person_name" else needGender
    needGender = True if type == "first_name" else needGender
    needGender = True if type == "last_name" else needGender
  if columns.__len__ == 0:
    return output

  created = 0
  for x in range(num):
    if not preview:
      item = iris.cls(self.className)._New()

    row = {}
    gender = fake.random_choices(elements=('M', 'F'), length=1)[0] if needGender else ""
    for columnInfo in columns:
      name, type = columnInfo
      value = ""
      try:
        typeMethod = getattr(self, "type_" + type)
        kwargs = {}
        varnames = typeMethod.__code__.co_varnames
        if "gender" in varnames:
          kwargs["gender"] = gender
        if "options" in varnames:
          kwargs["options"] = {}
        value = typeMethod(fake, **kwargs)

      except Exception as e:
        print(e)

      if preview:
        row[name] = value
      else:
        if hasattr(self, "convert_" + type):
          value = getattr(self, "convert_" + type)(value)
          output["status"].append(value)
        setattr(item, name, value)

    if preview:
      output["items"].append(row)
    else:
      status = item._Save()
      if not status:
        output["status"].append(status)
      itemId = item._Id()
      created += 1 if status and itemId else 0

  if not preview:
    output["created"] = created
  return output
}

Method options2Args(options, names) [ Language = python ]
{
  result = {}
  for name in names:
    if hasattr(options, name):
      result[name] = getattr(options, name)
  return result
}

/// Person
/// FullName
Method "type_person_name"(fake, gender) As %String(MAXLEN="") [ Language = python ]
{
  return fake.name_male() if gender == "M" else fake.name_female()
}

/// Person
/// FirstName
Method "type_first_name"(fake, gender) As %String(MAXLEN="") [ Language = python ]
{
  return fake.first_name_male() if gender == "M" else fake.first_name_female()
}

/// Person
/// LastName
Method "type_last_name"(fake, gender) As %String(MAXLEN="") [ Language = python ]
{
  return fake.last_name_male() if gender == "M" else fake.last_name_female()
}

/// Person
/// Gender
Method "type_gender"(fake, gender) As %String [ Language = python ]
{
  return gender
}

/// Person
/// DateOfBirth
/// @minimum_age:number:0
/// @maximum_age:number:115
Method "type_date_of_birth"(fake, options) As %Date [ Language = python ]
{
  kwargs = self.options2Args(options, ["minimum_age", "maximum_age"])
  return fake.date_of_birth(**kwargs).strftime(self.dateformat)
}

Method "convert_date_of_birth"(value As %String) As %Date
{
  Quit $ZDateh(value, 3)
}

/// Company
/// Name
Method "type_company_name"(fake) As %String(MAXLEN="") [ Language = python ]
{
  return fake.company()
}

/// Address
/// Full
Method "type_address"(fake) As %String(MAXLEN="") [ Language = python ]
{
  return fake.address()
}

/// Address
/// PostCode
Method "type_postcode"(fake) As %String(MAXLEN=10) [ Language = python ]
{
  return fake.postcode()
}

/// Address
/// Country
Method "type_country"(fake) As %String(MAXLEN=100) [ Language = python ]
{
  return fake.country()
}

/// Address
/// City
Method "type_city"(fake) As %String(MAXLEN=50) [ Language = python ]
{
  return fake.city()
}

/// Address
/// Street
Method "type_street_address"(fake) As %String(MAXLEN="") [ Language = python ]
{
  return fake.street_address()
}

/// Internet
/// Email
Method "type_email"(fake) As %String(MAXLEN="") [ Language = python ]
{
  return fake.email()
}

/// Internet
/// Company Email
Method "type_company_email"(fake) As %String(MAXLEN="") [ Language = python ]
{
  return fake.company_email()
}

/// Internet
/// Url
Method "type_url"(fake) As %String(MAXLEN="") [ Language = python ]
{
  return fake.url()
}

/// DateTime
/// Date
/// @start_date:string:-30y
/// @end_date:string
Method "type_date"(fake, options) As %Date [ Language = python ]
{
  kwargs = self.options2Args(options, ["start_date", "end_date"])
  return fake.date_between(**kwargs).strftime(self.dateformat)
}

Method "convert_date"(value As %String) As %Date
{
  Quit $ZDateh(value, 3)
}

/// Misc
/// Boolean
/// @chance_of_getting_true:number:50
Method "type_boolean"(fake, options) As %Boolean [ Language = python ]
{
  kwargs = self.options2Args(options, ["chance_of_getting_true"])
  return fake.boolean(**kwargs)
}

}
