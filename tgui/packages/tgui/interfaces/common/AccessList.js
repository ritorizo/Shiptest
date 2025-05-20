import { sortBy } from 'common/collections';
import { useLocalState } from '../../backend';
import { Button, Flex, Grid, Section, Tabs } from '../../components';

const diffMap = {
  0: {
    icon: 'times-circle',
    color: 'bad',
  },
  1: {
    icon: 'stop-circle',
    color: null,
  },
  2: {
    icon: 'check-circle',
    color: 'good',
  },
};

export const AccessList = (props, context) => {
  const {
    accesses = [],
    selected_accesses,
    accessMod,
    grantAll,
    denyAll,
  } = props;
  const [selectedAccessName, setSelectedAccessName] = useLocalState(
    context,
    'accessName',
    accesses[0]?.name
  );
  const selectedAccess = accesses.find(
    (access) => access.name === selectedAccessName
  );
  const selectedAccessEntries = sortBy((entry) => entry.desc)(
    selectedAccess?.accesses || []
  );

  return (
    <Section
      title="Access"
      buttons={
        <>
          <Button
            icon="check-double"
            content="Grant All"
            color="good"
            onClick={() => grantAll()}
          />
          <Button
            icon="undo"
            content="Deny All"
            color="bad"
            onClick={() => denyAll()}
          />
        </>
      }
    >
      <Flex>
        <Flex.Item>
          {accesses.map((entry) => (
            <Button.Checkbox
              fluid
              key={entry.desc}
              content={entry.desc}
              checked={selected_accesses & entry.ref}
              onClick={() => accessMod(entry.ref)}
            />
          ))}
        </Flex.Item>
      </Flex>
    </Section>
  );
};
