#include "En.h"

En::En(QObject *parent)
    : Lang{parent}
{
    setObjectName("En");
    home("Home");
    fjsjyt("Fujian EduDepartment");
    hquoa("HQU OA");
    hquid("HQU ID");
    popus("Popus");
    navigation("Navigation");
    theming("Theming");
    media("Media");
    dark_mode("Dark Mode");
    search("Search");
    about("About");
    settings("Settings");
    locale("Locale");
    navigation_view_display_mode("NavigationView Display Mode");
}
