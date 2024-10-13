#include <Geode/Geode.hpp>
#include <objc/runtime.h>
#include <UIKit/UIKit.h>
#include <imgui-cocos.hpp>

@interface EAGLView : UIView
@end

static IMP swapBuffersOIMP;
void swapBuffers(EAGLView* self, SEL sel) {
    static auto init = false;

    if (!init) {
        ImGuiCocos::get().setup();
        init = true;
    }

    if (ImGuiCocos::get().isInitialized())
        ImGuiCocos::get().drawFrame();

    reinterpret_cast<decltype(&swapBuffers)>(swapBuffersOIMP)(self, sel);
}

$execute {
    auto EAGLView = objc_getClass("EAGLView");
    auto swapBuffersMethod = class_getInstanceMethod(EAGLView, @selector(swapBuffers));
    swapBuffersOIMP = method_getImplementation(swapBuffersMethod);
    method_setImplementation(swapBuffersMethod, (IMP)&swapBuffers);
}