import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Flex,
  Input,
  NoticeBox,
  Section,
  Tabs,
} from '../components';
import { NtosWindow } from '../layouts';
import { AccessList } from './common/AccessList';

export const NtosCard = (props, context) => {
  return (
    <NtosWindow width={450} height={520} resizable>
      <NtosWindow.Content scrollable>
        <NtosCardContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosCardContent = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab, setTab] = useLocalState(context, 'tab', 1);
  const {
    authenticated,
    accesses = [],
    current_access,
    jobs = {},
    id_rank,
    id_owner,
    has_id,
    have_printer,
    have_id_slot,
    id_name,
    has_ship,
    id_has_ship_access,
    ship_has_unique_access,
  } = data;
  if (!have_id_slot) {
    return (
      <NoticeBox>
        This program requires an ID slot in order to function
      </NoticeBox>
    );
  }
  return (
    <>
      <Section
        title={
          has_id && authenticated ? (
            <Input
              value={id_owner}
              width="250px"
              onInput={(e, value) =>
                act('PRG_edit', {
                  name: value,
                })
              }
            />
          ) : (
            id_owner || 'No Card Inserted'
          )
        }
        buttons={
          <>
            <Button
              icon="print"
              content="Print"
              disabled={!have_printer || !has_id}
              onClick={() => act('PRG_print')}
            />
            <Button
              icon={authenticated ? 'sign-out-alt' : 'sign-in-alt'}
              content={authenticated ? 'Log Out' : 'Log In'}
              color={authenticated ? 'bad' : 'good'}
              onClick={() => {
                act(authenticated ? 'PRG_logout' : 'PRG_authenticate');
              }}
            />
          </>
        }
      >
        <Button
          fluid
          icon="eject"
          content={id_name}
          onClick={() => act('PRG_eject')}
        />
      </Section>
      {!!has_id && !!authenticated && (
        <Box>
          <Tabs>
            <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
              Access
            </Tabs.Tab>
            <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
              Jobs
            </Tabs.Tab>
            <Tabs.Tab selected={tab === 3} onClick={() => setTab(3)}>
              Ship Auth
            </Tabs.Tab>
          </Tabs>
          {tab === 1 && (
            <>
              {has_ship === 1 && (
                <Section
                  title={
                    'ID Ship Access: ' +
                    (id_has_ship_access ? 'Granted' : 'Denied')
                  }
                  buttons={
                    <Button
                      icon={id_has_ship_access ? 'user-minus' : 'user-plus'}
                      content={id_has_ship_access ? 'Deny' : 'Grant'}
                      color={id_has_ship_access ? 'bad' : 'good'}
                      onClick={() =>
                        act(
                          id_has_ship_access ? 'PRG_denyship' : 'PRG_grantship'
                        )
                      }
                    />
                  }
                />
              )}
              <AccessList
                accesses={accesses}
                selected_accesses={current_access}
                accessMod={(ref) =>
                  act('PRG_access', {
                    access_target: ref,
                  })
                }
              />
            </>
          )}
          {tab === 2 && (
            <Section
              title={id_rank}
              buttons={
                <Button.Confirm
                  icon="exclamation-triangle"
                  content="Terminate"
                  color="bad"
                  onClick={() => act('PRG_terminate')}
                />
              }
            >
              <Button.Input
                fluid
                content="Custom..."
                onCommit={(e, value) =>
                  act('PRG_assign', {
                    assign_target: 'Custom',
                    custom_name: value,
                  })
                }
              />
              <Flex>
                <Flex.Item grow={1}>
                  {jobs.map((job) => (
                    <Button
                      fluid
                      key={job}
                      content={job}
                      onClick={() =>
                        act('PRG_assign', {
                          assign_target: job,
                        })
                      }
                    />
                  ))}
                </Flex.Item>
              </Flex>
            </Section>
          )}
          {tab === 3 && has_ship === 1 && (
            <>
              <Section
                title={
                  'Unique Ship Access: ' +
                  (ship_has_unique_access ? 'Enabled' : 'Disabled')
                }
                buttons={
                  <Button
                    icon={ship_has_unique_access ? 'lock-open' : 'lock'}
                    content={ship_has_unique_access ? 'Disable' : 'Enable'}
                    color={ship_has_unique_access ? 'bad' : 'good'}
                    onClick={() =>
                      act(
                        ship_has_unique_access
                          ? 'PRG_disableuniqueaccess'
                          : 'PRG_enableuniqueaccess'
                      )
                    }
                  />
                }
              />
              <Section
                title="Print Silicon Access Chip"
                buttons={
                  <Button
                    icon="microchip"
                    content="Print"
                    color="good"
                    onClick={() => act('PRG_printsiliconaccess')}
                  />
                }
              />
            </>
          )}
        </Box>
      )}
    </>
  );
};
