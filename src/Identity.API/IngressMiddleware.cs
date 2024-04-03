namespace Identity.API;

public class IngressMiddleware(RequestDelegate next)
{
    private readonly RequestDelegate _next = next;

    public async Task Invoke(HttpContext context)
    {
        var configuration = context.RequestServices.GetRequiredService<IConfiguration>();
        if (configuration["Origin"] != null)
        {
            context.RequestServices.GetRequiredService<IServerUrls>().Origin = configuration["Origin"];
        }

        //if (configuration["PathBase"] != null)
        //{
        //    context.Request.PathBase = new PathString(configuration["PathBase"]);
        //}

        await _next(context);
    }
}
