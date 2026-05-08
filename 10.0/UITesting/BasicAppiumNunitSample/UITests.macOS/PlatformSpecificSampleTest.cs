using NUnit.Framework;

namespace UITests;

public class PlatformSpecificSampleTest : BaseTest
{
	[Test]
	public void SampleTest()
	{
		var screenshot = App.GetScreenshot();
		screenshot.SaveAsFile($"{nameof(SampleTest)}.png");

		// Assert that the Appium driver has an active session (app is running)
		Assert.That(App.SessionId, Is.Not.Null, "Appium session should be active on macOS");

		// Assert that the app's page source is loaded (UI is rendered)
		Assert.That(App.PageSource, Is.Not.Null.And.Not.Empty, "App page source should not be empty — macOS app must be rendered");

		// Assert that the screenshot was captured with real image data
		Assert.That(screenshot, Is.Not.Null, "Screenshot should be captured successfully");
		Assert.That(screenshot.AsByteArray, Is.Not.Empty, "Screenshot should contain image data");
	}
}