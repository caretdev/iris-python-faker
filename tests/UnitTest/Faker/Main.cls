Class UnitTest.caretdev.Faker.Main Extends %UnitTest.TestCase
{

Method TestMain()
{
  Set datatypes = 17
  Set previewRows = 5
  Set result = ##class("caretdev.Faker.Main").Test()
  If $$$ISERR(result) {
    Do $$$AssertStatusOK(result)
    Quit
  }

  Set columns = result."__getitem__"("columns")
  Set items = result."__getitem__"("items")
  Do $$$AssertEquals(columns."__len__"(), datatypes, "Correct amount of colummns")
  Do $$$AssertEquals(items."__len__"(), previewRows, "Correct amount of itemms in result")

  Set empty = 0
  For i=0:1:previewRows-1 {
    Set item = items."__getitem__"(i)
    For j=0:1:datatypes-1 {
      Set name = columns."__getitem__"(j)."__getitem__"("name")
      Set value = item."__getitem__"(name)
      if value = "" {
        Set empty = 1
        Quit
      }
    }
    Quit:empty
  }
  Do $$$AssertNotTrue(empty, "No empty values")
}

Method TestFromJSON()
{
  Set faker = ##class("caretdev.Faker.Main").%New()
  Set params = {
    "previewRows": 3,
    "locale": "en",
    "columns": [{
      "type": "person_name",
      "name": "name"
    }, {
      "type": "date_of_birth",
      "name": "dob"
    }]
  }
  Do faker.%JSONImport(params)
  Set result = faker.Generate()
  If $$$ISERR(result) {
    Do $$$AssertStatusOK(result)
    Quit
  }
  Do $$$AssertEquals(result."__getitem__"("columns")."__len__"(), 2, "Correct amount of colummns")
  Do $$$AssertEquals(result."__getitem__"("items")."__len__"(), 3, "Correct amount of itemms in result")
}

Method TestSave2Class()
{
  Set faker = ##class("caretdev.Faker.Main").%New()
  Set className = "IRISTemp.TestingFaker"
  Do $System.OBJ.Delete(className, "/nodisplay")
  Set params = {
    "rows": 3,
    "className": (className),
    "locale": "en",
    "columns": [{
      "type": "person_name",
      "name": "name"
    }, {
      "type": "date_of_birth",
      "name": "dob"
    }, {
      "type": "boolean",
      "name": "flag"
    }]
  }
  Do faker.%JSONImport(params)
  Quit:'$$$AssertStatusOK(faker.GenerateClass())
  Do $ClassMethod(className, "%KillExtent")

  Set result = faker.Generate()
  If $$$ISERR(result) {
    Do $$$AssertStatusOK(result)
    Quit
  }

  Do $$$AssertEquals(result."__getitem__"("created"), params.rows, "Correct amount of rows")

  Set tableName = ##class(%Dictionary.CompiledClass).%OpenId(className).SqlQualifiedNameQ
  Set sql = "SELECT * FROM " _ tableName
  Set rs = ##class(%SQL.Statement).%ExecDirect(,sql)
  Set rows = 0
  While rs.%Next() {
    Set rows = rows + 1
    Do $$$AssertNotEquals(rs.name, "", "name not empty")
    Do $$$AssertNotEquals(rs.dob, "", "dob not empty")
    Do $$$AssertNotEquals(rs.flag, "", "flag not empty")
  }
  Do $$$AssertEquals(rows, params.rows, "Real amount of rows in table")
}

}
