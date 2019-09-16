import React from 'react';
import { BrowserRouter, Route, Switch } from 'react-router-dom';
import Home from '../containers/Home';
import DocumentBrowser from '../containers/DocumentBrowser'
import Photo from '../containers/Photo'

export enum Routes {
  DocumentBrowser = '/files',
  Photo = "/photo",
  Home = '/',
}

export default () => {
  return (
    <BrowserRouter>
      <Switch>
        <Route path={Routes.DocumentBrowser} component={DocumentBrowser} />
        <Route path={Routes.Photo} component={Photo} />
        <Route path={Routes.Home} component={Home} />
      </Switch>
    </BrowserRouter>
  )
}
