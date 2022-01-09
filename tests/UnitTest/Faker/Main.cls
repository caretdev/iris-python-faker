Class UnitTest.caretdev.Faker.Main Extends %UnitTest.TestCase
{

Method TestMain()
{
  Set result = ##class("caretdev.Faker.Main").Test()
  Do $$$AssertEquals(result."__getitem__"("columns")."__len__"(), 16, "Correct amount of colummns")
  Do $$$AssertEquals(result."__getitem__"("items")."__len__"(), 5, "Correct amount of itemms in result")
}

Method TestFromJSON()
{
  Set faker = ##class("caretdev.Faker.Main").%New()
  Set params = {
    "seed": 1,
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
  Do $$$AssertEquals(result."__getitem__"("columns")."__len__"(), 2, "Correct amount of colummns")
  Do $$$AssertEquals(result."__getitem__"("items")."__len__"(), 3, "Correct amount of itemms in result")

  Set valuesList = $ListBuild(
    $ListBuild("Robert Brown", "1922-01-26"),
    $ListBuild("Kaitlyn Gray", "1934-08-06"),
    $ListBuild("Steven Price", "1988-09-10")
  )
  Set ptr = 0
  Set items = result."__getitem__"("items")
  For i = 1:1:$ListLength(valuesList) {
    Set values = $ListGet(valuesList, i)
    Set item = items."__getitem__"(i-1)
    Set $ListBuild(name, dob) = values
    Do $$$AssertEquals(item."__getitem__"("name"), name, "row = " _ i _ ", property = name")
    Do $$$AssertEquals(item."__getitem__"("dob"), dob, "row = " _ i _ ", property = dob")
  }
}

Method TestSave2Class()
{
  Set faker = ##class("caretdev.Faker.Main").%New()
  Set className = "IRISTemp.TestingFaker"
  Do $System.OBJ.Delete(className, "/nodisplay")
  Set params = {
    "seed": 1,
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

  Do $$$AssertEquals(result."__getitem__"("created"), params.rows, "Correct amount of rows")

  Set valuesList = $ListBuild(
    $ListBuild("Robert Brown", 29610, 0),
    $ListBuild("Jamie Clark", 48000, 1),
    $ListBuild("Pamela Smith", 45889, 1)
  )
  Set tableName = ##class(%Dictionary.CompiledClass).%OpenId(className).SqlQualifiedNameQ
  Set sql = "SELECT * FROM " _ tableName
  Set rs = ##class(%SQL.Statement).%ExecDirect(,sql)
  Set row = 0
  While rs.%Next() {
    Set row = row + 1
    Set $ListBuild(name, dob, flag) = $ListGet(valuesList, row)
    Do $$$AssertEquals(rs.name, name, "row = " _ row _ ", property = name")
    Do $$$AssertEquals(rs.dob, dob, "row = " _ row _ ", property = dob")
    Do $$$AssertEquals(rs.flag, flag, "row = " _ row _ ", property = flag")
  }
}

}
