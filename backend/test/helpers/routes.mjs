export function findRoute(router, method, path) {
  const lowerMethod = method.toLowerCase();
  return router.stack.find(
    (layer) =>
      layer.route &&
      layer.route.path === path &&
      Boolean(layer.route.methods?.[lowerMethod])
  )?.route;
}

export function routeHasMiddleware(route, middleware) {
  if (!route?.stack) {
    return false;
  }
  return route.stack.some((layer) => layer.handle === middleware);
}
