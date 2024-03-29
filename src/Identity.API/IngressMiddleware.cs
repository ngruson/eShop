namespace Identity.API;

public class IngressMiddleware(RequestDelegate next)
{
    private readonly RequestDelegate _next = next;

    public async Task Invoke(HttpContext context)
    {
        context.RequestServices.GetRequiredService<IServerUrls>().BasePath = context.Request.PathBase.Value + "/identityapi";

        await _next(context);
    }
}
