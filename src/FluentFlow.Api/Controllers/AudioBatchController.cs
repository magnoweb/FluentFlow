using Microsoft.AspNetCore.Mvc;

namespace FluentFlow.Api.Controllers;

public class AudioBatchController : Controller
{
    // GET
    public IActionResult Index()
    {
        return View();
    }
}