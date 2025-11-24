import React from 'react';

function StatusDisplay({ status }) {
  if (!status || !status.message) {
    return null;
  }

  const statusClass = `status status-${status.type}`;

  return (
    <div className={statusClass}>
      <span>{status.message}</span>
    </div>
  );
}

export default StatusDisplay;

