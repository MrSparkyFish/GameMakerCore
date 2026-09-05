// Feather disable all

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// You're welcome to use any of the following macros in your game but ... //
//                                                                        //
//                       DO NOT EDIT THIS SCRIPT                          //
//                       Bad things might happen.                         //
//                                                                        //
//          Customisation options can be found in __InputConfig().        //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

#macro vk_clear       0x0C
#macro vk_capslock    0x14
#macro vk_menu        0x5D
#macro vk_scrollock   0x91
 
#macro vk_semicolon   0xBA
#macro vk_comma       0xBC
#macro vk_fslash      0xBF
#macro vk_bslash      0xDC
#macro vk_lbracket    0xDB
#macro vk_rbracket    0xDD

#macro vk_numlock     ((INPUT_APPLE &&  INPUT_WEB)                    ? 0x0C : 0x90)
#macro vk_equals      ((INPUT_MACOS && !INPUT_WEB)                    ? 0x18 : 0xBB)
#macro vk_apostrophe (((INPUT_MACOS || INPUT_LINUX)  && !INPUT_WEB)? 0xC0 : 0xDE)
#macro vk_hyphen     (((INPUT_MACOS || INPUT_SWITCH) && !INPUT_WEB)? 0x6D : 0xBD)
#macro vk_rmeta        (INPUT_MACOS? ((INPUT_APPLE   &&  INPUT_WEB)? 0x5D : 0x5B) : 0x5C)
#macro vk_backtick    (!INPUT_MACOS?  (INPUT_LINUX                    ? 0xDF : 0xC0) : 0x32)
#macro vk_lmeta        (INPUT_MACOS                                      ? 0x5C : 0x5B)
#macro vk_period       (INPUT_SWITCH                                     ? 0x6E : 0xBE)

#macro vk_a ord("A")
#macro vk_b ord("B")
#macro vk_c ord("C")
#macro vk_d ord("D")
#macro vk_e ord("E")
#macro vk_f ord("F")
#macro vk_g ord("G")
#macro vk_h ord("H")
#macro vk_i ord("I")
#macro vk_j ord("J")
#macro vk_k ord("K")
#macro vk_l ord("L")
#macro vk_m ord("M")
#macro vk_n ord("N")
#macro vk_o ord("O")
#macro vk_p ord("P")
#macro vk_q ord("Q")
#macro vk_r ord("R")
#macro vk_s ord("S")
#macro vk_t ord("T")
#macro vk_u ord("U")
#macro vk_v ord("V")
#macro vk_w ord("W")
#macro vk_x ord("X")
#macro vk_y ord("Y")
#macro vk_z ord("Z")

#macro vk_0 ord("0")
#macro vk_1 ord("1")
#macro vk_2 ord("2")
#macro vk_3 ord("3")
#macro vk_4 ord("4")
#macro vk_5 ord("5")
#macro vk_6 ord("6")
#macro vk_7 ord("7")
#macro vk_8 ord("8")
#macro vk_9 ord("9")


#macro mb_wheel_up    m_scroll_up
#macro mb_wheel_down  m_scroll_down

//Valid keycode bounds
#macro INPUT_KEYCODE_MIN  8
#macro INPUT_KEYCODE_MAX  57343