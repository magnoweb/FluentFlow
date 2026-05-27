using Microsoft.AspNetCore.Mvc;

namespace FluentFlow.Api.Controllers;

public class LogsController : Controller
{
    // GET
    public IActionResult Index()
    {
        return View();
    }
}