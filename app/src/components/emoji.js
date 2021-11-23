import React, { Component } from 'react';

const Emoji = props => (
    <span
      style={{ fontSize: 25 }}
      role="img"
      aria-label={props.label ? props.label : ""}
      aria-hidden={props.label ? "false" : "true"}
    >
      {props.symbol}
    </span>
  )

  export default Emoji;