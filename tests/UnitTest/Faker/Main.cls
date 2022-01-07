Class UnitTest.caretdev.Faker.Main Extends %UnitTest.TestCase
{

Method TestMain()
{
  Set result = ##class("caretdev.Faker.Main").Test()
  Do $$$AssertEquals(result."__getitem__"("columns")."__len__"(), 16, "Correct amount of colummns")
  Do $$$AssertEquals(result."__getitem__"("items")."__len__"(), 5, "Correct amount of itemms in result")
}

}
