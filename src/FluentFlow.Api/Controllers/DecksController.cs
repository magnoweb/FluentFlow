using Microsoft.AspNetCore.Mvc;

namespace FluentFlow.Api.Controllers;

public class DecksController : Controller
{
    // GET
    public IActionResult Index()
    {
        return View();
    }
}