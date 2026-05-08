using NUnit.Framework;

namespace UITests;

public class PlatformSpecificSampleTest : BaseTest
{
	[Test]
	public void SampleTest()
	{
		var screenshotPath = $"{nameof(SampleTest)}.png";
		App.GetScreenshot().SaveAsFile(screenshotPath);

		Assert.That(App, Is.Not.Null, "Appium driver session should be initialized for the BrowserStack run.");
		Assert.That(App.SessionId, Is.Not.Null, "BrowserStack session id should be available once the driver is connected.");
		Assert.That(App.PageSource, Is.Not.Null.And.Not.Empty, "App page source should be retrievable from the Windows driver.");
		Assert.That(System.IO.File.Exists(screenshotPath), Is.True, "Screenshot file should be written to disk.");
	}
}
