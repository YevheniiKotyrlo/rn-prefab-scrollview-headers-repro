// The view headers are in the react-android prefab, so this include resolves.
#include <react/renderer/components/view/ViewComponentDescriptor.h>
// The scrollview headers are not, so this include fails, although libreactnative.so exports ScrollView's symbols.
#include <react/renderer/components/scrollview/ScrollViewComponentDescriptor.h>

namespace facebook::react {

ComponentDescriptorProvider scrollViewComponentDescriptorProvider() {
  return concreteComponentDescriptorProvider<ScrollViewComponentDescriptor>();
}

} // namespace facebook::react
