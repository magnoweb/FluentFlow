using Microsoft.AspNetCore.Mvc;

namespace FluentFlow.Api.Controllers;

public class CardsController : Controller
{
    // GET
    public IActionResult Index()
    {
        return View();
    }
}