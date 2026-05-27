using Microsoft.AspNetCore.Mvc;

namespace FluentFlow.Api.Controllers;

public class StudyController : Controller
{
    // GET
    public IActionResult Index()
    {
        return View();
    }
}