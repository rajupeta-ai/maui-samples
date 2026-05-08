using NUnit.Framework;

namespace UITests;

public class PlatformSpecificSampleTest : BaseTest
{
	[Test]
	public void SampleTest()
	{
		App.GetScreenshot().SaveAsFile($"{nameof(SampleTest)}.png");

		Assert.That(App, Is.Not.Null, "AppiumDriver session should be initialized");
		Assert.That(App.SessionId, Is.Not.Null, "AppiumDriver session id should be active");

		var counterBtn = FindUIElement("CounterBtn");
		Assert.That(counterBtn, Is.Not.Null, "CounterBtn element should be present on the launched page");
		Assert.That(counterBtn.Displayed, Is.True, "CounterBtn element should be displayed on screen");
	}
}
