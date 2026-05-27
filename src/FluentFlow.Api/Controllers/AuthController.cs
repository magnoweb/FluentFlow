using Microsoft.AspNetCore.Mvc;

namespace FluentFlow.Api.Controllers;

public class AuthController : Controller
{
    // GET
    public IActionResult Index()
    {
        return View();
    }
}