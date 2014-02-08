/*
 * Frog Pond Evolution
 * Copyright (c) 2013 Michael S. Horn
 * 
 *           Michael S. Horn (michael-horn@northwestern.edu)
 *           Northwestern University
 *           2120 Campus Drive
 *           Evanston, IL 60613
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License (version 2) as
 * published by the Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */
part of ComputerHistory;


class PageManager {
  
  // current page
  int curr_page = 0;

  // list of page ids
  List<String> pages;

  
  PageManager() {
    
    // init page list
    pages = new List<String>();
    var pagelist = querySelectorAll(".page");
    for (Element page in pagelist) {
      pages.add(page.id);
    }
    
    bindClickEvents("next-button", (e) => nextPage());
    bindClickEvents("back-button", (e) => prevPage());
  }
  
  
//-------------------------------------------------------------------------
// called once for the beginning of each turn
//-------------------------------------------------------------------------
  void loadPage(String id) {
    setHtmlVisibility("next-button", true);
    setHtmlVisibility("back-button", true);
  }


//-------------------------------------------------------------------------
// Go to an arbitrary page
//-------------------------------------------------------------------------
  void gotoPage(int page) {
    page = page % pages.length;
    Element el = querySelector("#${pages[page]}");
    if (el != null) {
      loadPage(el.id);
      el.style.animation = "slidein-left 0.5s ease-in 0 1";
      el.style.left = "0px";
    }
  }
  
  
//-------------------------------------------------------------------------
// slide page onto the screen
//-------------------------------------------------------------------------  
  void slidePageIn(String id, bool left) {
    loadPage(id);
    Element el = querySelector("#${id}");
    if (left) {
      el.style.animation = "slidein-left 0.5s ease-in-out 0 1";
      el.style.left = "0px";
    } else {
      el.style.animation = "slidein-right 0.5s ease-in-out 0 1";
      el.style.left = "0px";
    }
  }
  
  
//-------------------------------------------------------------------------
// slide page off of the screen
//-------------------------------------------------------------------------
  void slidePageOut(String id, bool left) {
    Element el = querySelector("#${id}");
    if (left) {
      el.style.animation = "slideout-left 0.5s ease-in-out 0 1";
      el.style.left = "-2000px";  // iPad2 -1050px
    } else {
      el.style.animation = "slideout-right 0.5s ease-in-out 0 1";
      el.style.left = "2000px"; // iPad2 1050px;
    }
  }
  
  
//-------------------------------------------------------------------------
// Advance to the next page
//-------------------------------------------------------------------------
  void nextPage() {
    int p0 = curr_page;
    int p1 = (p0 + 1) % pages.length;
    
    slidePageOut(pages[p0], true);
    slidePageIn(pages[p1], true);
    curr_page = p1;
  }
  
  
//-------------------------------------------------------------------------
// Back to the previous page
//-------------------------------------------------------------------------
  void prevPage() {
    int p0 = curr_page;
    int p1 = p0 - 1;
    if (p1 < 0) p1 = pages.length - 1;
    slidePageOut(pages[p0], false);
    slidePageIn(pages[p1], false);
    curr_page = p1;
  }
}
